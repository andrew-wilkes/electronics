extends Control

const PART_PATH = "res://assets/parts/small/part-"

var map = {
	"DC": 3,
	"AC": 0,
	"VOLTS": 15,
	"AMPS": 1,
	"R": 12,
	"C": 2,
	"POT": 11,
	"Diode": 4,
	"FET": 6,
	"ECap": 5,
	"Zener": 16,
	"OP": 10,
	"LED": 9,
	"L": 7,
	"T1": 13,
	"T2": 14,
	"Lamp": 8
}

func get_part_path(pname):
	return PART_PATH + str(map[pname]) + ".png"


func get_part(pname):
	for node in get_children():
		if node.name == pname:
			var part = node.duplicate()
			part.type = pname
			part.data = node.data
			part.setup()
			return part
