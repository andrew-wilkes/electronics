extends HBoxContainer

signal probe_view_pressed(view)

var view = false
var hidden_icon = preload("res://assets/icons/icon_GUI_visibility_hidden.svg")
var visible_icon = preload("res://assets/icons/icon_GUI_visibility_visible.svg")
var num = 1
var trace_color

func _ready():
	set_button_icon()
	trace_color = $Color.color


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
	trace_color = color
