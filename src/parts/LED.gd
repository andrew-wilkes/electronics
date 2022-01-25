extends Part

var current = 0.02 setget set_brightness

func _init():
	data = { hue = 0 }


func set_data(v):
	data = v
	$HSlider.value = data.hue
	set_color()


func _on_HSlider_value_changed(value):
	data.hue = value
	set_color()


func set_brightness(i):
	current = i
	set_color()


func set_color():
	# 50mA max
	var value = 1.0 if current < 0.05 else 0.0
	$C/Tex.modulate = Color.from_hsv(data.hue / 100, 50 * clamp(current, 0, 0.02), value)
