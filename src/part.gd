extends GraphNode

class_name Part

export var flipped = false
export var is_gnd = false
export var is_mirrored = false
export var inc_from_pin = false
export var isolated = false
export var series = false

const part_vals = [1, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 4.7, 6.8, 8.2]

var type = ""
var data = {} setget set_data, get_data
var gnd # Reference to ground node
var r = INF setget ,get_r
var l = INF
var c = 0.0

func get_r(_port = 0):
	return r


func _ready():
	if get_parent().name == "Grid":
		show_name()


func show_name():
	var label = Label.new()
	label.text = name
	add_child(label)


func set_data(v):
	data = v

func get_data():
	return data


func setup():
	pass


func apply_cv(pin, cv, gnds):
	if pin in gnds:
		cv[1] = 0
	return cv
