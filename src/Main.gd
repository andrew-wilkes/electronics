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
var pgs: Dictionary
var gnd_names = []
var from_tos: Dictionary
var net
var loops
var dc_loops
var net_nodes
var cvs = []

func _ready():
	set_process(false)
	probe_holder = $Main/Tools/Probes
	Parts.hide()
	add_part_buttons()
	graph = $Main/Grid
	Data.load_settings()
	setup_menus()


func test():
	update_network()
	prints("from_tos", from_tos)
	prints("gnds", pgs.gnds)
	print("net_nodes", net_nodes)


func update_network():
	pgs = get_parts_and_gnds(graph)
	from_tos = get_from_tos(pgs, graph)
	pgs.gnds = get_gnd_nodes(from_tos, pgs.gnds)
	net_nodes = get_net_nodes(from_tos)
	loops = get_loops(pgs, net_nodes)
	prints("loops", loops)
	minimize_loops(loops)
	dc_loops = get_dc_loops(loops)
	cvs.clear()
	for _n in loops.size():
		cvs.append([0, 0, 0]) # C, V, GND offset voltage


func get_gnd_nodes(from_tos_, gnd_names_):
	var gnds_ = []
	for key in from_tos_.keys():
		if key[0] in gnd_names_:
			for to in from_tos_[key]:
				gnds_.append(to)
		else:
			for to in from_tos_[key]:
				if to[0] in gnd_names_:
					gnds_.append(key)
	return gnds_


func simulate(dt, pgs_, loops_, cvs_):
	var idx = 0
	for loop in loops_:
		# The cvs_[idx] value travels around the loop
		for pin in loop:
			cvs_[idx] = pgs_.parts[pin[0]].apply_cv(pin, pgs_.gnds, cvs_[idx], dt)
		idx += 1


func get_net_nodes(from_tos_):
	var net_nodes_ = []
	for from in from_tos_.keys():
		var node = from_tos_[from]
		if goes_to_existing_node(from, node, net_nodes_):
			continue
		node.append(from)
		net_nodes_.append(node)
	return net_nodes_


func goes_to_existing_node(from, node, net_nodes_):
	for net_node_ in net_nodes_:
			for to in node:
				if to in net_node_:
					net_node_.append(from)
					return true
	return false


func get_from_tos(pgs_, graph_):
	# Array [{ from: [name, port, side], tos: [[name, port, side], ...]
	var nodes = {}
	var cons = graph_.get_connection_list()
	for con in cons:
		# Cons may have a common from value
		var from_side = 0 if pgs_.parts[con.from].is_mirrored else 1
		var from_port = con.from_port
		if from_port > 0 and pgs_.parts[con.from].inc_from_pin:
			from_port += 1
		var from = [con.from, from_port, from_side]
		var to = [con.to, con.to_port, 0] # to, to_port, left side
		var found = false
		for _from in nodes.keys():
			if _from == from: # Found an existing `from` node so append the `to` value and break
				nodes[from].append(to)
				found = true
				break
			# The `_from` node is not `from` but may be connected to `from` parent node at the same port number as `from`. In mirrored pgs_.parts, the io pins for a port number are shorted together.
			if from_side == 0: # Search in 'tos' for existing connection
				for _to in nodes[_from]:
					if _to == from: # Matching [name, port]
						found = true
						break
				if found:
					# Make `_from` node connect to the same `to` as `from`.
					# Also don't add this `from` to the node list since its redundent
					nodes[_from].append(to)
					break
		if not found: # Add new node
			nodes[from] = [to]
	return nodes


func get_parts_and_gnds(_graph):
	var _parts = {}
	var _gnd_names = []
	for node in _graph.get_children():
		if node is GraphNode:
			_parts[node.name] = node
			if node.is_gnd:
				_gnd_names.append(node.name)
	return { parts = _parts, gnds = _gnd_names }


func get_loops(pgs_, net_nodes_):
	var loops_ = []
	# Get loops from net
	for node in net_nodes_:
		for pin in node:
			if not_in_loop(loops_, pin):
				var stack = []
				var _e = try_get_loop(pin, node, stack, pgs_, loops_)
				var out_pin = false
				for pin_ in stack:
					# Assign sinks only for the pins connecting to the next part in the loop
					if out_pin:
						assign_sinks_to_part(pin_, pgs_, net_nodes_)
					out_pin = not out_pin
	return loops_

"""
Algorithm to extract independent mesh windows

Compare 2 loops

Find common sequence of 3 or more nodes (cs)

Designate the loops A and B where B is the shortest loop

Replace inner nodes of cs in A with reversed B nodes minus cs nodes
"""
func minimize_loops(loops_):
	var idxa = 0
	while idxa < loops_.size() - 1:
		var idxb = idxa + 1
		# Look for subsequence of A in B
		var a1 = -1
		var b1 = -1
		for ai in loops_[idxa].size():
			var i = loops_[idxb].find(loops_[idxa][ai])
			if i > -1:
				a1 = ai
				b1 = i
				break
		if b1 > -1:
			var ai = a1
			var bi = b1
			var a2
			var b2
			var run_length = 1
			while true:
				ai += 1
				# Wrap ai
				if ai == loops_[idxa].size():
					ai = 0
				bi += 1
				# Wrap bi
				if bi == loops_[idxb].size():
					bi = 0
				if loops_[idxa][ai] != loops_[idxb][bi]:
					break
				a2 = ai
				b2 = bi
				run_length += 1
			if run_length > 2:
				# Got a subsequence
				if loops_[idxa].size() > loops_[idxb].size():
					var l = shrink_loop(idxa, idxb, a1, a2, b2, run_length, loops_)
					loops_[idxa] = loops_[idxb]
					loops_[idxb] = l
				else:
					loops_[idxb] = shrink_loop(idxb, idxa, b1, b2, a2, run_length, loops_)
		idxa += 1


func shrink_loop(idxa, idxb, a1, a2, b2, run_length, loops_):
	var b_nodes = []
	for i in run_length - 2:
		b2 -= 1
		if b2 < 0:
			b2 = loops_[idxb].size() - 1
		b_nodes.append(loops_[idxb][b2])
	var loopa
	if a2 > a1:
		loopa = loops_[idxa].slice(0, a1)
		loopa.append_array(b_nodes)
		loopa = loops_[idxa].slice(a2, -1)
	else:
		loopa = loops_[idxa].slice(a2, a1)
		loopa.append_array(b_nodes)
	return loopa


func get_dc_loops(loops_):
	var regex = RegEx.new()
	regex.compile("^L\\d*")
	var dc_loops_ = []
	for loop_ in loops_:
		var is_loop = true
		var dc_loop = []
		for part in loop_:
			if part[0].begins_with("ECap") or part[0].begins_with("C"):
				is_loop = false
				break
				# skip inductors
			if  not regex.search(part[0]):
				dc_loop.append(part)
		if is_loop:
			dc_loops_.append(dc_loop)
	return dc_loops_


func assign_sinks_to_part(pin, pgs_, net_nodes_):
	for node in net_nodes_:
		for el in node:
			if el == pin:
				# The part is joined to node
				var part = pgs_.parts[pin[0]]
				calc_thev(part, pgs_, get_related_nodes(node, net_nodes_, pin, pgs_))
				return


# This handles the case of voltage sources that need to connect together (short) nodes
func get_related_nodes(pins, net_nodes_, pin, pgs_):
	var all_pins = pins.duplicate()
	for el in pins:
		if el != pin:
			if pgs_.parts[el[0]].is_voltage_source:
				all_pins.erase(el)
				var other_pin = [el[0], (el[1] + 1) % 2, el[2]]
				for nn in net_nodes_:
					for el_ in nn:
						if el_ == other_pin:
							all_pins.append_array(nn)
							all_pins.erase(other_pin)
							for n in nn:
								if n != other_pin and pgs_.parts[n[0]].is_voltage_source:
									all_pins.append_array(get_related_nodes(nn, net_nodes_, n, pgs_))
									all_pins.erase(n)
							break
				
	return all_pins


func calc_thev(part: Part, pgs_, node):
	part.c_th = 0
	part.sinks = []
	for el in node:
		if el[0] != part.name:
			var p = pgs_.parts[el[0]]
			# Deal with special cases such as a voltage source
			part.sinks.append([p, el[1], el[2]])
	part.r_th = calc_rl(part.sinks, "r")
	part.l_th = calc_rl(part.sinks, "l")
	for s in part.sinks:
		part.c_th += s[0].c
	prints(part.name, part.r_th, part.l_th, part.c_th)


func calc_rl(sinks, rl):
	var x = INF
	var xs = []
	for s in sinks:
		if s[0][rl] < 0.1:
			x = s[0][rl]
			return
		if s[0].r != INF:
			xs.append(s[0][rl])
	for n in xs:
		if x == INF:
			x = 1 / n
		else:
			x += 1 / n
	if x == 0:
		return INF
	else:
		return 1 / x


func not_in_loop(_loops, start):
	for loop in _loops:
		if loop.has(start):
			return false
	return true


func try_get_loop(from_pin, start_node, stack_, pgs_, loops_):
	for to_node in net_nodes:
		for to_pin in to_node:
			# Find another pin on the same part
			if to_pin != from_pin and from_pin[0] == to_pin[0]:
				# If isolated, the pin must be on same side
				if pgs_.parts[to_pin[0]].isolated and from_pin[2] != to_pin[2]:
					continue
				# If tagged as series, new pin must be adjacent
				if pgs_.parts[to_pin[0]].series:
					if abs(from_pin[1] - to_pin[1]) > 1.1:
						continue
				# Can't connect to itself
				if to_pin in stack_:
					continue
				# Can't connect to node that already has 2 connections
				var n = 0
				for pin in to_node:
					if pin in stack_:
						n += 1
				if n > 1:
					continue
				# The pin is OK to add to the loop
				stack_.append(from_pin)
				stack_.append(to_pin)
				# Check for completion of the loop
				if to_node == start_node:
					loops_.append(stack_)
					prints("Stack:", stack_)
					return true
				# Get next pin on same node
				for pin in to_node:
					# Can't have the same pin in a loop
					if not pin in stack_:
						if try_get_loop(pin, start_node, stack_, pgs_, loops_):
							return true
	return false

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
			update_network()
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
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			update_network()


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
	yield(get_tree(), "idle_frame") # Ensure that nodes are freed
	yield(get_tree(), "idle_frame")
	set_changed(false)
	var probes_data = graph_data.probes
	for node_data in graph_data.nodes:
		# Get new node from factory autoload (singleton)
		var gnode = Parts.get_part(node_data.type)
		gnode.offset = node_data.offset
		gnode.name = node_data.name
		gnode.data = node_data.data
		graph.add_child(gnode, true)
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
		vac = false,
		iac = false,
	}
	# Add probe to dict or replace nulled value
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
	probe_info.view.connect("probe_color_changed", self, "probe_color_changed", [pid])
	probe_info.view.setup(pid)


func update_probe(pid):
	var p = probes[pid]
	if p.view.show_v:
		p.view.update_v(p.part.volts[1][p.from_slot], p.vac)
	if p.view.show_i:
		p.view.update_i(p.part.amps[1][p.from_slot], p.iac)


func probe_color_changed(color, pid):
	probes[pid].marker.get_child(0).modulate = color


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


func _on_Run_pressed():
	set_process(true)
	test()


func _process(_d):
	simulate(0.02, pgs, loops, cvs)
	for pid in probes:
		update_probe(pid)
