extends Part

signal r_changed(v)
signal p_changed(v)

const r_vals = [1, 10, 100]

func _init():
	data = { r = 1, p = 0.5 }


func get_r(_port = 0):
	match _port:
		0:
			return data.r * 1000 * (1.0 - data.p)
		1:
			return data.r * 1000 * (1.0 - data.p) * data.p
		2:
			return data.r * 1000 * data.p
	return r


func _on_HSlider_value_changed(value):
	data.r = value
	set_text(value)
	emit_signal("r_changed", value)


func set_data(v):
	data = v
	$M/HBox/VBox/HSlider.value = data.r
	set_text(data.r)
	$M/HBox/VSlider.value = data.p


func set_text(v):
	$M/HBox/VBox/Label.text = str(r_vals[v]) + "K"


func _on_VSlider_value_changed(value):
	data.p = value
	emit_signal("p_changed", value)
