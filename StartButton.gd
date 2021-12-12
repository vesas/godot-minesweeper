extends Button

signal hud_button_pressed

func _pressed():
	emit_signal("hud_button_pressed")
