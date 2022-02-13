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
var amps = [[[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]]]
var time = 0

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


func get_current(_port, _side):
	return (Vector2(amps[_side][_port][R], 0) + Vector2(0, amps[_side][_port][L]) + Vector2(0, -amps[_side][_port][C])).length()


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


func set_irs(port, side, dv):
	var irs = 0
	for s in sinks:
		irs += s[PART].set_ir(s[SIDE], s[PORT], dv)
	amps[R][side][port] = irs


func set_ils(port, side, dv, dt):
	var ils = 0
	for s in sinks:
		ils += s[0].set_il(s[SIDE], s[PORT], dv, dt)
	amps[L][side][port] = ils


func set_ics(port, side, dv, dt):
	var ics = 0
	for s in sinks:
		ics += s[PART].set_ic(s[SIDE], s[PORT], dv, dt)
	amps[C][side][port] = ics


func apply_cv(pin, gnds, dt):
	var dv = delta_v(get_voltage(pin[PORT], pin[SIDE]), get_current(pin[PORT], pin[SIDE]), get_total_i(L) * l_th, get_total_i(R) * r_th, dt)
	# Affect the node elements
	set_irs(pin[PORT], pin[SIDE], dv)
	set_ils(pin[PORT], pin[SIDE], dv, dt)
	set_ics(pin[PORT], pin[SIDE], dv, dt)
	volts[pin[SIDE]][pin[PORT]] += dv
	if pin in gnds:
		volts[pin[SIDE]][pin[PORT]] = 0
	time += dt
