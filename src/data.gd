extends Node

const SETTINGS_FILE_NAME = "user://settings.res"

var settings: Settings


func load_settings():
	var data = load_resource(SETTINGS_FILE_NAME)
	if data is Settings: # Check that the data is valid
		settings = data
	else:
		settings = Settings.new()


func save_settings():
	save_resource(SETTINGS_FILE_NAME, settings)


func load_resource(file_name):
	if ResourceLoader.exists(file_name):
		return ResourceLoader.load(file_name)


func save_resource(file_name, data):
	assert(ResourceSaver.save(file_name, data) == OK)


func save_data(file_name, graph: GraphEdit, probes):
	var graph_data = GraphData.new()
	for pid in probes.keys():
		var probe = probes[pid]
		var info = { id = pid, slot = probe.slot }
		if graph_data.probes.has(probe.part.name):
			graph_data.probes[probe.part.name].append(info)
		else:
			graph_data.probes[probe.part.name] = [info]
	graph_data.connections = graph.get_connection_list()
	for node in graph.get_children():
		if node is GraphNode:
			var node_data = NodeData.new()
			node_data.name = node.name
			node_data.type = node.type
			node_data.offset = node.offset
			node_data.data = node.data
			graph_data.nodes.append(node_data)
	graph_data.scroll_offset = graph.scroll_offset
	graph_data.zoom = graph.zoom
	graph_data.snap_distance = graph.snap_distance
	graph_data.use_snap = graph.use_snap
	graph_data.minimap_enabled = graph.minimap_enabled
	return ResourceSaver.save(file_name, graph_data)


func load_data(file_name):
	if ResourceLoader.exists(file_name):
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is GraphData:
			return graph_data


func get_file_content(path) -> String:
	var content = ""
	var file = File.new()
	if file.open(path, File.READ) == OK:
		content = file.get_as_text()
		file.close()
	return content
