extends Part

signal vac_changed(v)

func _init():
	data = { vac = 120 }


func _on_VSlider_value_changed(value):
	data.vac = value
	set_text(value)
	emit_signal("vac_changed", value)


func set_data(v):
	data = v
	$M/HBox/VSlider.value = data.vac
	set_text(data.vac)


func set_text(v):
	$M/HBox/VBox/Label.text = str(v) + "V"


func get_voltage(_port, _side):
	return volts[_port]
