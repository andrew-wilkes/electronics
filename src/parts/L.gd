extends Part

signal l_changed(v)

const m_vals = [char(0xB5) + "H", "mH", "mH"]

func _init():
	data = { L = 1 }


func _on_HSlider_value_changed(value):
	data.c = value
	set_text(value)
	emit_signal("l_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.L
	set_text(data.L)


func set_text(v):
	var mult = floor(v) # 1 - 5
	v = fmod(v, 1) * 10 # fractional part * 10 to give 0 - 9
	var pow_ten = pow(10, fmod(mult, 3)) # What power of 10 to multiply the rval by
	var n = part_vals[v] * pow_ten
	l = n * [1e-6, 1e-3, 1e-3][(mult - 1) / 2]
	$Label.text = str(n) + m_vals[(mult - 1) / 2]


func get_il(_port, _side, dv):
	volts[_side][_port] += dv
	var v
	if flipped:
		v = volts[_side][1] - volts[_side][0]
		if _port == 1:
			v = -v
	else:
		v = volts[1][0] - volts[0][0]
		if _side == 1:
			v = -v
	return v / r


func set_il(_port, _side, dv, dt):
	volts[_side][_port] += dv
	var v
	if flipped:
		v = volts[0][1] - volts[0][0]
	else:
		v = volts[0][0] - volts[0][1]
	if _port == 1 or _side == 1:
		v = -v
	amps[L][0][0] += v * dt / l
	amps[L][0][1] = -amps[L][0][0] 
	amps[L][1][0] = amps[L][0][1]
	return amps[L][_side][_port]
