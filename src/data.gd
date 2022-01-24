extends Node

const GRAPH_FILE = "user://graph.res"

func save_data(graph: GraphEdit):
	var graph_data = GraphData.new()
	graph_data.connections = graph.get_connection_list()
	for node in graph.get_children():
		if node is GraphNode:
			var node_data = NodeData.new()
			node_data.name = node.name
			node_data.type = node.type
			node_data.offset = node.offset
			node_data.data = node.data
			graph_data.nodes.append(node_data)
	if ResourceSaver.save(GRAPH_FILE, graph_data) == OK:
		print("saved")


func load_data():
	if ResourceLoader.exists(GRAPH_FILE):
		var graph_data = ResourceLoader.load(GRAPH_FILE)
		if graph_data is GraphData:
			return graph_data


func get_file_content(path) -> String:
	var content = ""
	var file = File.new()
	if file.open(path, File.READ) == OK:
		content = file.get_as_text()
		file.close()
	return content
