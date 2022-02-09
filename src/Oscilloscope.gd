extends Control

func _ready():
	yield(get_tree(), "idle_frame")
	rect_min_size.y = round(0.8 * rect_size.x)
	get_data_texture()


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


# Create an RGBA8 image texture of wave data
func get_data_texture():
	var rgba = PoolByteArray([])
	var num_samples = int(rect_size.x)
	for n in num_samples:
		var a = 128 + 100 * sin(PI * 4 * n / num_samples)
		var b = (n % 60) * 250.0 / 60.0
		var c = 100 if a > 128 else 20
		var d = n % 50
		d = n * 3 if a > 128 else -n * 3
		rgba.append(a)
		rgba.append(b)
		rgba.append(c)
		rgba.append(d)
	var img = Image.new()
	img.create_from_data(num_samples, 1, false, Image.FORMAT_RGBA8, rgba)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	material.set_shader_param("traces", texture)
	img.save_png("res://temp.png")
