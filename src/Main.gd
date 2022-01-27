extends Control

var graph: GraphEdit
var selected_nodes = {}
var probes = {}
var probe_scene = preload("res://Probe.tscn")

func _ready():
	Parts.hide()
	add_part_buttons()
	graph = $Main/Grid
	Data.load_settings()
	var graph_data = Data.load_data()
	if graph_data != null and true:
		init_graph(graph_data)


func add_part_buttons():
	for pname in Parts.map.keys():
		var b = TextureButton.new()
		b.texture_normal = ResourceLoader.load(Parts.get_part_path(pname))
		b.hint_tooltip = Parts.map[pname][1]
		b.connect("pressed", self, "part_pressed", [pname])
		var c = CenterContainer.new()
		c.add_child(b)
		$Top/Parts.add_child(c)


func part_pressed(pname):
	var part = Parts.get_part(pname)
	part.offset = (graph.rect_size / 2 + Vector2(rand_range(-40, 40), rand_range(-40, 40)) + graph.scroll_offset) / graph.zoom
	part.set("custom_constants/port_offset", 0)
	graph.add_child(part, true)


func init_graph(graph_data: GraphData):
	clear_graph()
	var probes_data = graph_data.probes
	for node_data in graph_data.nodes:
		# Get new node from factory autoload (singleton)
		var gnode = Parts.get_part(node_data.type)
		gnode.offset = node_data.offset
		gnode.name = node_data.name
		gnode.data = node_data.data
		graph.add_child(gnode)
		if probes_data.has(node_data.name):
			for p_list in probes_data[node_data.name]:
				add_probe(gnode, p_list.slot, p_list.id)
	for con in graph_data.connections:
		var _e = graph.connect_node(con.from, con.from_port, con.to, con.to_port)



func clear_graph():
	graph.clear_connections()
	var nodes = graph.get_children()
	for node in nodes:
		if node is GraphNode:
			remove_probes(node)
			node.queue_free()
	probes = {}


func _on_Grid_connection_request(from, from_slot, to, to_slot):
	var _e = graph.connect_node(from, from_slot, to, to_slot)


func _on_Grid_disconnection_request(from, from_slot, to, to_slot):
	graph.disconnect_node(from, from_slot, to, to_slot)


func _on_Grid_node_selected(node):
	selected_nodes[node] = true


func _on_Grid_node_unselected(node):
	selected_nodes[node] = false


func _on_Grid_delete_nodes_request():
	for node in selected_nodes.keys():
		if selected_nodes[node]:
			remove_connections_to_node(node)
			remove_probes(node)
			node.queue_free()
	selected_nodes = {}


func remove_connections_to_node(node):
	for con in graph.get_connection_list():
		if con.to == node.name or con.from == node.name:
			graph.disconnect_node(con.from, con.from_port, con.to, con.to_port)


func remove_probes(node):
	for probe in probes:
		if probe.node == node:
			# Remove trace if any
			probe.view.queue_free()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Data.save_data(graph, probes)
		Data.save_settings()


func _on_Grid_connection_to_empty(from, from_slot, _release_position):
	var node: GraphNode = find_part(from)
	add_or_remove_probe(node, from_slot)


func add_or_remove_probe(node, from_slot):
	# Remove existing probe
	for pid in probes.keys():
		if probes[pid] != null and probes[pid].part == node and probes[pid].slot == from_slot:
			probes[pid].view.queue_free()
			probes[pid].marker.queue_free()
			probes[pid] = null
			return
	add_probe(node, from_slot, get_probe_id())


func add_probe(node, from_slot, pid):
	var marker = Node2D.new()
	marker.position = node.get_connection_output_position(from_slot) / graph.zoom  + Vector2(6, -20)
	var probe = Label.new()
	marker.add_child(probe)
	node.add_child(marker)
	var probe_info = {
		part = node,
		slot = from_slot,
		marker = marker,
		view = probe_scene.instance(),
	}
	# Add probe to dict or replace nulled value
	probe_info.view.setup(pid)
	$Main/Tools.add_child(probe_info.view)
	probes[pid] = probe_info
	probe.text = "P" + str(pid)


func get_probe_id():
	var n = 1
	for pid in probes.keys():
		if probes[pid] == null:
			n = pid
			break
		n = pid + 1
	return n


func find_part(pname):
	for node in graph.get_children():
		if node.name == pname:
			return node
