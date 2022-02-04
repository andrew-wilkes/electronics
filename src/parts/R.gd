extends Part

signal r_changed(v)

const m_vals = ["R", "K", "M"]

func _init():
	data = { r = 3 }


func _on_HSlider_value_changed(value):
	data.r = value
	set_text(value)
	emit_signal("r_changed", value)


func set_data(v):
	data = v
	r = data.r
	$HSlider.value = data.r
	set_text(data.r)


func set_text(v):
	var mult = floor(v) # 0 - 6
	v = fmod(v, 1) * 10 # fractional part * 10 to give 0 - 9
	var pow_ten = pow(10, fmod(mult, 3)) # What power of 10 to multiply the part_val by
	$Label.text = str(part_vals[v] * pow_ten) + m_vals[mult / 3]


var pd = 0

func apply_cv(pin, cv, gnds):
	cv = .apply_cv(pin, cv, gnds)
	pd = data.r * cv[0]
	if not is_mirrored:
		# Simulate output from other resistor pin
		cv[1] -= pd
	return cv
