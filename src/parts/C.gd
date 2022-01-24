extends Part

signal c_changed(v)

func _init():
	data = { c = 10 }


func _on_HSlider_value_changed(value):
	data.c = value
	set_text(value)
	emit_signal("c_changed", value)


func set_data(v):
	data = v
	$HSlider.value = data.c
	set_text(data.c)


func set_text(v):
	$Label.text = str(v) + "nF"
