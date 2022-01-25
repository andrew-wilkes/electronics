extends Control

const PART_PATH = "res://assets/parts/small/part-"

var map = {
	"DC": [3, "DC power supply"],
	"AC": [0, "AC power supply"],
	"VOLTS": [16, "Voltmeter"],
	"AMPS": [1, "Ammeter"],
	"R": [12, "Resistor"],
	"C": [2, "Capacitor"],
	"POT": [11, "Variable resistor"],
	"Diode": [4, "Diode"],
	"SDiode": [13, "Schottky diode"],
	"FET": [6, "Transistor"],
	"ECap": [5, "Electrolytic capacitor"],
	"Zener": [17, "Zener diode"],
	"OP": [10, "Op-amp or Comparator"],
	"LED": [9, "LED"],
	"L": [7, "Inductor"],
	"T1": [14, "Transformer"],
	"T2": [15, "Center-tapped transformer"],
	"Lamp": [8, "Lamp"],
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
