extends Control

func _ready():
	Parts.hide()
	add_part_buttons()

func add_part_buttons():
	for pname in Parts.map.keys():
		var b = TextureButton.new()
		b.texture_normal = ResourceLoader.load(Parts.get_part_path(pname))
		b.connect("pressed", self, "part_pressed", [pname])
		var c = CenterContainer.new()
		c.add_child(b)
		$Top/Parts.add_child(c)


func part_pressed(pname):
	var part = Parts.get_part(pname)
	part.offset = Vector2($Main/Grid.rect_size.x / 2, 20)
	part.set("custom_constants/port_offset", 0)
	$Main/Grid.add_child(part)
