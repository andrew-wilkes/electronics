extends Control

func _ready():
	yield(get_tree(), "idle_frame")
	rect_min_size.y = round(0.8 * rect_size.x)
	set_process(true) # For testing


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


func combine_samples(traces: Array):
	var rgba = PoolByteArray([])
	match traces.size():
		1:
			for n in traces[0].size():
				rgba.append(traces[0][n])
				rgba.append(0)
				rgba.append(0)
				rgba.append(0)
		2:
			for n in traces[0].size():
				rgba.append(traces[0][n] / 2)
				rgba.append(traces[1][n] / 2 + 128)
				rgba.append(0)
				rgba.append(0)
		3:
			for n in traces[0].size():
				rgba.append(traces[0][n] / 3)
				rgba.append(traces[1][n] / 3 + 85)
				rgba.append(traces[2][n] / 3 + 170)
				rgba.append(0)
		4:
			for n in traces[0].size():
				rgba.append(traces[0][n] / 4)
				rgba.append(traces[1][n] / 4 + 64)
				rgba.append(traces[2][n] / 4 + 128)
				rgba.append(traces[3][n] / 4 + 192)
	return rgba

var phase = 0

# Create an RGBA8 image texture of wave data
func test_sine():
	var traces = [[], [], [], []]
	var num_samples = int(rect_size.x)
	for n in num_samples:
		var a = 128 + 120 * sin(n / 20.0 + phase)
		var b = 128 + 110 * cos(n / 20.0 + phase)
		var c = 240 if a > 128 else 30 # square wave
		var d = (n * 4 + int(phase * 20)) % 200 + 25 # sawtooth
		traces[0].append(a)
		traces[1].append(b)
		traces[2].append(c)
		traces[3].append(d)
	show_traces(combine_samples(traces))


func show_traces(rgba):
	var img = Image.new()
	img.create_from_data(rgba.size() / 4, 1, false, Image.FORMAT_RGBA8, rgba)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	material.set_shader_param("traces", texture)


func _process(_delta):
	test_sine()
	phase += 0.1
