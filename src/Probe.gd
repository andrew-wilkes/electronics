extends HBoxContainer

class_name Probe

signal probe_view_pressed(id, IV, show)
signal probe_color_changed(color)

enum { I, V }

const SAMPLE_SIZE = 10

var show_v = false
var show_i = false
var hidden_icon = preload("res://assets/icons/icon_GUI_visibility_hidden.svg")
var visible_icon = preload("res://assets/icons/icon_GUI_visibility_visible.svg")
var id = 1
var vac = []
var iac = []
var sample_index = 0
var time = 0
var sample_time = 0.1
var last_v = INF
var last_i = INF

func _ready():
	set_button_icon($VTrace, show_v)
	set_button_icon($ITrace, show_i)
	for n in SAMPLE_SIZE:
		vac.append(0)
		iac.append(0)


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
	emit_signal("probe_color_changed", $Color.color)


func set_button_icon(b, show):
	if show:
		b.texture_normal = hidden_icon
	else:
		b.texture_normal = visible_icon


func _on_ColorPickerButton_color_changed(color):
	Data.settings.trace_colors[id] = color
	emit_signal("probe_color_changed", color)


func _on_VTrace_pressed():
	show_v = !show_v
	set_button_icon($VTrace, show_v)
	emit_signal("probe_view_pressed", id, V, show_v)


func _on_ITrace_pressed():
	show_i = !show_i
	set_button_icon($ITrace, show_i)
	emit_signal("probe_view_pressed", id, I, show_i)


func update_v(v, _vac, dt):
	if v == last_v:
		return
	var s = ""
	if _vac:
		s = "rms"
		time -= dt
		if time < 0:
			time = sample_time
			vac[sample_index] = v * v
			sample_index += 1
			if sample_index == SAMPLE_SIZE:
				sample_index = 0
				v = 0
				for vs in vac:
					v += vs
				v = sqrt(v / SAMPLE_SIZE)
	# Scale
	if v < 1:
		v *= 1000
		$V.text = str(int(v)) + "mV" + s
	else:
		$V.text = str(int(v)) + "V" + s


func update_i(i, _iac, dt):
	if i == last_i:
		return
	var s = ""
	if _iac:
		s = "rms"
		time -= dt
		if time < 0:
			time = sample_time
			iac[sample_index] = i * i
			sample_index += 1
			if sample_index == SAMPLE_SIZE:
				sample_index = 0
				i = 0
				for _is in iac:
					i += _is
				i = sqrt(i / SAMPLE_SIZE)
	# Scale
	if i < 1:
		i *= 1000
		$I.text = str(int(i)) + "mA" + s
	else:
		$I.text = str(int(i)) + "A" + s
