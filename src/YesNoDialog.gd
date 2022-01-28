extends WindowDialog

signal yes
signal no

func _on_Yes_pressed():
	emit_signal("yes")


func _on_No_pressed():
	emit_signal("no")
