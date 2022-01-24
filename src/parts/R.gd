extends Part

signal r_changed(v)

const rvals = [1, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 4.7, 6.8, 8.2]
const mvals = ["R", "R", "R", "K", "K", "K", "M"]

func _init():
	data = { r = 3 }


func _on_HSlider_value_changed(value):
	data.r = value
	set_text(value)
	emit_signal("r_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.r
	set_text(data.r)


func set_text(v):
	var mult = floor(v)
	v = (v - int(v)) * 10
	var zeros = pow(10, fmod(mult, 3))
	$Label.text = str(rvals[v] * zeros) + mvals[mult]
