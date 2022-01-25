extends ColorRect

func _ready():
	rect_size.y = round(0.8 * rect_size.x)


func _draw():
	var grid_spacing = rect_size.x / 10
	var x = rect_size.x
	var y = grid_spacing
	for row in 7:
		draw_line(Vector2(0, y), Vector2(x, y), Color.black, 1.0)
		y += grid_spacing
	y = rect_size.y
	x = grid_spacing
	for col in 9:
		draw_line(Vector2(x, 0), Vector2(x, y), Color.black, 1.0)
		x += grid_spacing
	# Draw 4 ticks inbetween lines
	x = rect_size.x / 2 - 2
	y = grid_spacing / 5
	for row in 8:
		for n in 4:
			draw_line(Vector2(x, y), Vector2(x + 3, y), Color.black, 1.0)
			y += grid_spacing / 5
		y += grid_spacing / 5
	x = grid_spacing / 5
	y = rect_size.y / 2 - 2
	for col in 10:
		for n in 4:
			draw_line(Vector2(x, y), Vector2(x, y + 4), Color.black, 1.0)
			x += grid_spacing / 5
		x += grid_spacing / 5
