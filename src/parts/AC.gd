extends Part

signal vac_changed(v)

var two_pi_f = 2 * PI * 50

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


func apply_cv(pin, cv, gnds, dt):
	.apply_cv(pin, cv, gnds, dt)
	var v = sin(two_pi_f * time) * data.vac
	if pin == 0:
		volts[1] = volts[0] - v
	else:
		volts[0] = volts[1] + v
