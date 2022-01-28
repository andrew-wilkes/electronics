extends HBoxContainer

signal probe_view_pressed(id, IV, show)

enum { I, V }

var showV = false
var showI = false
var hidden_icon = preload("res://assets/icons/icon_GUI_visibility_hidden.svg")
var visible_icon = preload("res://assets/icons/icon_GUI_visibility_visible.svg")
var id = 1

func _ready():
	set_button_icon($VTrace, showV)
	set_button_icon($ITrace, showI)


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


func set_button_icon(b, show):
	if show:
		b.texture_normal = hidden_icon
	else:
		b.texture_normal = visible_icon


func _on_ColorPickerButton_color_changed(color):
	Data.settings.trace_colors[id] = color


func _on_VTrace_pressed():
	showV = !showV
	set_button_icon($VTrace, showV)
	emit_signal("probe_view_pressed", id, V, showV)


func _on_ITrace_pressed():
	showI = !showI
	set_button_icon($ITrace, showI)
	emit_signal("probe_view_pressed", id, I, showI)
