extends HBoxContainer

signal probe_view_pressed(view)

var view = false
var hidden_icon = preload("res://assets/icons/icon_GUI_visibility_hidden.svg")
var visible_icon = preload("res://assets/icons/icon_GUI_visibility_visible.svg")
var id = 1

func _ready():
	set_button_icon()


func setup(_id = 1):
	id = _id
	$P.text = "P" + str(id)
	$V.text = "12V"
	$I.text = "120mA"
	if Data.settings.trace_colors.has(id):
		$Color.color = Data.settings.trace_colors[id]
	else:
		$Color.color = Color.from_hsv(randf(), 0.8, 1.0)
		Data.settings.trace_colors[id] = $Color.color


func _on_View_pressed():
	view = !view
	set_button_icon()
	emit_signal("probe_view_pressed", view)


func set_button_icon():
	if view:
		$View.texture_normal = hidden_icon
	else:
		$View.texture_normal = visible_icon


func _on_ColorPickerButton_color_changed(color):
	Data.settings.trace_colors[id] = color
