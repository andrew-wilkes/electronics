extends Part

signal ratio_changed(ratio)

func _init():
	data = { ratio = 10 }


func set_data(v):
	data = v
	show_ratio()
	$HSlider.value = data.ratio


func _on_HSlider_value_changed(value):
	data.ratio = value
	show_ratio()
	emit_signal("ratio_changed", value)


func show_ratio():
	var r = "1:1:1"
	if data.ratio > 10:
		r = "1:" + str(data.ratio - 9) + ":" + str(data.ratio - 9)
	if data.ratio < 10:
		r = str(11 - data.ratio) + ":1:1"
	$Label.text = r
