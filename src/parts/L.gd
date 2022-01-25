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
	$Label.text = str(part_vals[v] * pow_ten) + m_vals[(mult - 1) / 2]
