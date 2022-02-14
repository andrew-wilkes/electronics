extends Part

signal vdc_changed(v)

func _init():
	data = { vdc = 12 }


func _on_VSlider_value_changed(value):
	data.vdc = value
	set_text(value)
	emit_signal("vdc_changed", value)


func set_data(v):
	data = v
	$M/HBox/VSlider.value = data.vdc
	set_text(data.vdc)


func set_text(v):
	$M/HBox/VBox/Label.text = str(v) + "V"


func apply_cv(pin, gnds, cv, dt):
	cv = .apply_cv(pin, gnds, cv, dt)
	if pin == 0:
		volts[1] = volts[0] - data.vdc
	else:
		volts[0] = volts[1] + data.vdc
	return cv
