extends GraphNode

class_name Part

export var flipped = false
export var is_gnd = false
export var is_mirrored = false
export var inc_from_pin = false
export var isolated = false
export var series = false
export var is_voltage_source = false

enum { PART, PORT, SIDE }
enum { R, C, L }
enum { I, V }

const part_vals = [1, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 4.7, 6.8, 8.2]

var type = ""
var data = {} setget set_data, get_data
var gnd # Reference to ground node
var r = INF setget ,get_r
var l = INF
var c = 0.0
var sinks = [] # Array of nodes [[part object, port num, side num], ...]
var r_th
var l_th
var c_th
var volts = [[0, 0, 0], [0, 0, 0]]
var amps = [[0, 0, 0], [0, 0, 0]]
var time = 0
var loops = {} # refs of loops that this part belongs to loop: direction of current +/- 1

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


func thevenin(rvs):
	var v = 0
	var _r = 0
	for rv in rvs:
		v += rv[1] / rv[0]
		_r += 1 / rv[0]
	return [1 / _r, v / _r]


# This is requested by connected parts
func get_voltage(_port, _side):
	return volts[_side][_port]


func get_current(_port, _side):
	return 


func get_sink_current():
	var i = 0
	for s in sinks:
		i += s[PART].amps[s[SIDE]][s[PORT]]
	return i


# The effect of this is specific to each type of part
func update_vout(_port, _side, _cv, _dt):
	return _cv


func apply_cv(pin, gnds, cv, dt):
	# The pins voltage and current will not be changed, but applied to this part and the sinks
	cv[0] -=  get_sink_current()
	if pin in gnds:
		cv[2] = -cv[1] # Set GND voltage offset for measurement purposes
	cv = update_vout(pin[PORT], pin[SIDE], cv, dt)
	time += dt
	return cv
