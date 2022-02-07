extends GraphNode

class_name Part

export var flipped = false
export var is_gnd = false
export var is_mirrored = false
export var inc_from_pin = false
export var isolated = false
export var series = false

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
var amps = [[[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]]]

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


func delta_v(v1, i1, vl, vr, dt):
	var v = dt * dt * (v1 - vl) / l + dt  * (v1 - vr) / r - i1 / r / l
	return v / c


# This is requested by connected parts
func get_voltage(_port, _side):
	return volts[_side][_port]


# The effect of this is specific to each type of part
func update_current(_port, _side, _v, _dv, _dt):
	pass


func set_ir(_port, _side, _dv):
	return 0


func set_il(_port, _side, _dv, _dt):
	return 0


func set_ic(_port, _side, _dv, _dt):
	return 0


func get_total_i(rcl):
	var i = 0
	for s in sinks:
		i += s[PART].amps[rcl][s[SIDE]][s[PORT]]
	return i


func set_irs(dv):
	var irs = 0
	for s in sinks:
		irs += s[PART].set_ir(s[SIDE], s[PORT], dv)
	return irs


func set_ils(dv, dt):
	var ils = 0
	for s in sinks:
		ils += s[0].set_il(s[SIDE], s[PORT], dv, dt)
	return ils


func set_ics(dv, dt):
	var ics = 0
	for s in sinks:
		ics += s[PART].set_ic(s[SIDE], s[PORT], dv, dt)
	return ics

# Calc v0
# Calc dv
# Get currents
# Update cv
func apply_cv(pin, cv, gnds, dt):
	if pin in gnds:
		cv[V] = 0
	var dv = delta_v(cv[V], cv[I], get_total_i(L) * l_th, get_total_i(R) * r_th, dt)
	# Affect the node elements
	cv[I] = (Vector2(set_irs(dv), 0) + Vector2(0, set_ils(dv, dt)) + Vector2(0, -set_ics(dv, dt))).length_squared()
	cv[V] += dv
	return cv
