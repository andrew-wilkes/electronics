extends Control

const PART_PATH = "res://assets/parts/small/part-"

var map = {
	"AC": [0, "AC power supply"],
	"DC": [2, "DC power supply"],
	"R": [11, "Resistor"],
	"C": [1, "Capacitor"],
	"ECap": [4, "Electrolytic capacitor"],
	"POT": [10, "Variable resistor"],
	"Diode": [3, "Diode"],
	"SDiode": [12, "Schottky diode"],
	"FET": [5, "Transistor"],
	"Zener": [15, "Zener diode"],
	"OP": [9, "Op-amp or Comparator"],
	"L": [6, "Inductor"],
	"T1": [13, "Transformer"],
	"T2": [14, "Center-tapped transformer"],
	"LED": [8, "LED"],
	"Lamp": [7, "Lamp"],
}

func get_part_path(pname):
	return PART_PATH + str(map[pname][0]) + ".png"


func get_part(pname):
	for node in get_children():
		if node.name == pname:
			var part = node.duplicate()
			part.type = pname
			part.data = node.data
			part.setup()
			return part
