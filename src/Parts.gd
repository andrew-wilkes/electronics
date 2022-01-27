extends Control

const PART_PATH = "res://assets/parts/small/part-"

var map = {
	"AC": [0, "AC power supply"],
	"DC": [3, "DC power supply"],
	"RA": [14, "Resistor"],
	"RB": [13, "Resistor"],
	"CA": [2, "Capacitor"],
	"CB": [1, "Capacitor"],
	"ECap": [6, "Electrolytic capacitor"],
	"POT": [12, "Variable resistor"],
	"DA": [5, "Diode"],
	"DB": [4, "Diode"],
	"SDA": [15, "Schottky diode"],
	"SDB": [16, "Schottky diode"],
	"FET": [7, "Transistor"],
	"Zener": [19, "Zener diode"],
	"OP": [11, "Op-amp or Comparator"],
	"L": [8, "Inductor"],
	"T1": [17, "Transformer"],
	"T2": [18, "Center-tapped transformer"],
	"LED": [10, "LED"],
	"Lamp": [9, "Lamp"],
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
