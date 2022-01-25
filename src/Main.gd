extends Control

var graph
var selected_nodes = {}

func _ready():
	Parts.hide()
	add_part_buttons()
	graph = $Main/Grid
	var graph_data = Data.load_data()
	if graph_data != null and false:
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
	part.offset = Vector2(graph.rect_size.x / 2, 20)
	part.set("custom_constants/port_offset", 0)
	graph.add_child(part)


func init_graph(graph_data: GraphData):
	clear_graph()
	for node in graph_data.nodes:
		# Get new node from factory autoload (singleton)
		var gnode = Parts.get_part(node.type)
		gnode.offset = node.offset
		gnode.name = node.name
		gnode.data = node.data
		graph.add_child(gnode)
	for con in graph_data.connections:
		var _e = graph.connect_node(con.from, con.from_port, con.to, con.to_port)


func clear_graph():
	graph.clear_connections()
	var nodes = graph.get_children()
	for node in nodes:
		if node is GraphNode:
			node.queue_free()


func _on_Grid_connection_request(from, from_slot, to, to_slot):
	graph.connect_node(from, from_slot, to, to_slot)


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
			node.queue_free()
	selected_nodes = {}


func remove_connections_to_node(node):
	for con in graph.get_connection_list():
		if con.to == node.name or con.from == node.name:
			graph.disconnect_node(con.from, con.from_port, con.to, con.to_port)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Data.save_data(graph)


func _on_Grid_connection_to_empty(from, from_slot, release_position):
	pass # Replace with function body.
