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


func set_ir(_port, _side, dv):
	volts[_side][_port] += dv
	var v
	if flipped:
		v = volts[0][1] - volts[0][0]
	else:
		v = volts[0][0] - volts[0][1]
	if _port == 1 or _side == 1:
		v = -v
	amps[R][0][0] += v / r
	amps[R][0][1] = -amps[L][0][0] 
	amps[R][1][0] = amps[L][0][1]
	return amps[L][_side][_port]
