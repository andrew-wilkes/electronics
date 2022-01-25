extends Part

const z_vals = [1.2, 2.5, 5]

signal z_changed(v)

func _init():
	data = { zv = 1 }


func _on_HSlider_value_changed(value):
	data.zv = value
	set_text(value)
	emit_signal("z_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.zv
	set_text(data.zv)


func set_text(v):
	$Label.text = str(z_vals[v]) + "V"
