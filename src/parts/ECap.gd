extends Part

signal ec_changed(v)

func _init():
	data = { c = 1 }


func _on_HSlider_value_changed(value):
	data.c = value
	set_text(value)
	emit_signal("ec_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.c
	set_text(data.c)


func set_text(v):
	var mult = floor(v) # 0 - 5
	v = fmod(v, 1) * 10 # fractional part * 10 to give 0 - 9
	var pow_ten = pow(10, mult) # What power of 10 to multiply the part_val by
	var n = part_vals[v] * pow_ten
	c = 1e-6 * n
	$Label.text = str(n) + char(0xB5) + "F" # Need symbol font. New code point for micro is: 03BC
