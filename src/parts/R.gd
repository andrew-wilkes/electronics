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
	$HSlider.value = data.r
	set_text(data.r)


func set_text(v):
	var mult = floor(v) # 0 - 6
	v = fmod(v, 1) * 10 # fractional part * 10 to give 0 - 9
	var pow_ten = pow(10, fmod(mult, 3)) # What power of 10 to multiply the part_val by
	var n = part_vals[v] * pow_ten
	r = n * [1, 1000, 1000000][mult / 3]
	$Label.text = str(n) + m_vals[mult / 3]


func update_vout(port, side, cv, _dt):
	volts[side][port] = cv[V]
	amps[side][port] = -cv[I]
	cv[V] -= cv[I] * r
	if flipped:
		var out_side = [1, 0][side]
		amps[out_side][port] = cv[I]
		volts[out_side][port] = cv[V]
	else:
		var out_port = [1, 0][port]
		amps[side][out_port] = cv[I]
		volts[side][out_port] = cv[V]
	return cv
