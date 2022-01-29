extends Control

enum { NOACTION, NEW, OPEN, SAVE, SAVEAS, SETTINGS, QUIT, ABOUT, LICENCES, MANUAL }

var graph: GraphEdit
var selected_nodes = {}
var probes = {}
var probe_scene = preload("res://Probe.tscn")
var probe_holder
var action = NOACTION
var file_name = ""
var last_file_name = ""
var changed = false

func _ready():
	probe_holder = $Main/Tools/Probes
	Parts.hide()
	add_part_buttons()
	graph = $Main/Grid
	Data.load_settings()
	setup_menus()


func get_loops():
	var cons = graph.get_connection_list()
	var loops = []
	var parts = {}
	var parts_in_loop = []
	var gnds = []
	# Get parts
	for node in graph.get_children():
		if node is GraphNode:
			if node.is_gnd:
				gnds.append(node)
			else:
				parts[node.name] = node
	# Get loops
	var start = cons[0]
	while start:
		var part = start
		parts.erase(start.from)
		var loop = [start.from]
		parts_in_loop = []
		while true:
			# find part connected to from current part
			var next
			for con in cons:
				if con.from == part.to and parts.keys().has(part.to):
					loop.append(part.to)
					# Assign gnds
					for gnd in gnds:
						if part.to == gnd.name or part.from == gnd.name:
							parts[start.from].gnd = gnd
					parts.erase(part.to)
					next = con.to
					break
			if next:
				part = next
			else:
				break
			if part == start:
				break
		# Check for completed loop
		if loop[0] == loop.pop_back():
			loops.append(loop)
		# Get next start
		start = null
		for con in cons:
			if parts.keys().has(con.from):
				start = con.from
				break


func setup_menus():
	var fm = $Top/FileMenu.get_popup()
	fm.add_item("New", NEW, KEY_MASK_CTRL | KEY_N)
	fm.add_item("Open", OPEN, KEY_MASK_CTRL | KEY_O)
	fm.add_separator()
	fm.add_item("Save", SAVE, KEY_MASK_CTRL | KEY_S)
	fm.add_item("Save As...", SAVEAS, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	fm.add_separator()
	fm.add_item("Quit", QUIT, KEY_MASK_CTRL | KEY_Q)
	fm.connect("id_pressed", self, "file_menu_id_pressed")


func file_menu_id_pressed(id):
	action = id
	match id:
		NEW, OPEN:
			confirm_loss()
		SAVE:
			do_action()
		SAVEAS:
			set_filename()
			action = SAVE
			do_action()
		QUIT:
			get_tree().quit()


func confirm_loss():
	if changed:
		$c/YesNoDialog.popup_centered()
	else:
		do_action()


func _on_YesNoDialog_no():
	$c/YesNoDialog.hide()
	do_action()


func _on_YesNoDialog_yes():
	$c/YesNoDialog.hide()
	action = SAVE
	do_action()


func do_action():
	match action:
		NEW:
			set_changed(false)
			set_filename()
			clear_graph()
		OPEN:
			open_file_dialog()
		SAVE:
			if file_name == "":
				$c/FileDialog.current_file = file_name
				$c/FileDialog.mode = FileDialog.MODE_SAVE_FILE
				$c/FileDialog.popup_centered()
			else:
				save_data()
		QUIT:
			get_tree().quit()


func save_data():
	if Data.save_data(file_name, graph, probes) != OK:
		alert("Failed to save the circuit file.")


func open_file_dialog():
	$c/FileDialog.current_file = file_name
	$c/FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$c/FileDialog.popup_centered()


func _on_FileDialog_file_selected(path: String):
	if path.rstrip("/") == path.get_base_dir():
		alert("No filename was specified")
		return
	set_filename(path)
	if action == SAVE:
		save_data()
		set_changed(false)
	else:
		var graph_data = Data.load_data(file_name)
		if graph_data == null:
			$Top/CurrentFile.text = ""
			alert("Incompatible file")
		else:
			init_graph(graph_data)


func set_filename(fn = ""):
	last_file_name = file_name
	file_name = fn
	$Top/CurrentFile.text = fn.get_file()


func alert(txt = ""):
	if txt != "":
		$c/Alert.dialog_text = txt
	$c/Alert.popup_centered()


func hide_alert():
	$c/Alert.hide()


func set_changed(status = true):
	changed = status
	$Top/CurrentFile.modulate = Color.orangered if status else Color.greenyellow


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
	set_changed(false)
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
	graph.scroll_offset = graph_data.scroll_offset
	graph.zoom = graph_data.zoom
	graph.snap_distance = graph_data.snap_distance
	graph.use_snap = graph_data.use_snap
	graph.minimap_enabled = graph_data.minimap_enabled


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
	for id in probes.keys():
		if probes[id].part == node:
			# Remove trace if any
			probes[id].view.queue_free()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_data()
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
	if probe_holder.get_child_count() == 0:
		probe_holder.add_child(probe_info.view)
	else:
		if pid == 1:
			probe_holder.add_child(probe_info.view)
			probe_holder.move_child(probe_info.view, 0)
		else:
			var _probes = probe_holder.get_children()
			_probes.invert()
			for child in _probes:
				if child.id < pid:
					probe_holder.add_child_below_node(child, probe_info.view)
					break
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


func _on_Alert_confirmed():
	$c/Alert.hide()
