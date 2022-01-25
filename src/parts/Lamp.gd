extends Part

func set_brightness(b): # 0 - 1.0
	# when the filament of a light bulb is heated slowly its colour changes from red to orange to yellow and eventually to white
	var h = 0
	var s = 1
	var v = b
	if b < 0.6:
		h = b / 3.6 # red to yellow
	else:
		h = 1.0 / 6
		s = (1.0 - v) / 0.4
	$C/Tex.modulate = Color.from_hsv(h, s, v)
