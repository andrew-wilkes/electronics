extends Part

signal c_changed(v)

func _init():
	data = { c = 1 }


func _on_HSlider_value_changed(value):
	data.c = value
	set_text(value)
	emit_signal("c_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.c
	set_text(data.c)


func set_text(v):
	var mult = floor(v) # 0 - 4
	v = fmod(v, 1) * 10 # fractional part * 10 to give 0 - 9
	var pow_ten = pow(10, mult) # What power of 10 to multiply the part_val by
	var n = part_vals[v] * pow_ten
	c = 1e-9 * n
	$Label.text = str(n) + "nF"


func set_ic(_port, _side, dv, dt):
	volts[_side][_port] += dv
	# The current flows into port 0 and out of port 1
	var i = c * dv / dt
	if _port == 1 or _side == 1:
		i = -i
	amps[L][0][0] = i
	amps[L][0][1] = -amps[L][_side][0]
	amps[L][1][0] = amps[L][0][1]
	return amps[L][_side][_port]
