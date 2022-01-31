extends GraphNode

class_name Part

export var flipped = false
export var is_gnd = false
export var is_mirrored = false

const part_vals = [1, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 4.7, 6.8, 8.2]

var type = ""
var data = {} setget set_data, get_data
var gnd # Reference to ground node

func _ready():
	pass


func set_data(v):
	data = v

func get_data():
	return data


func setup():
	pass
