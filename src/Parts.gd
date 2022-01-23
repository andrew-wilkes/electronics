extends Control

const PART_PATH = "res://assets/parts/small/part-"

var map = {
	"dc": 3,
	"ac": 0,
	"volts": 15,
	"amps": 1,
	"r": 12,
	"c": 2,
	"pot": 11,
	"diode": 4,
	"q": 6,
	"ecap": 5,
	"zener": 16,
	"op": 10,
	"led": 9,
	"l": 7,
	"t1": 13,
	"t2": 14,
	"lamp": 8
}

func _ready():
	if get_parent().name != "root":
		hide()

func get_part_path(pname):
	return PART_PATH + str(map[pname]) + ".png"
