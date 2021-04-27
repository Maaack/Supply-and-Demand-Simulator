extends Panel


signal continue_button_pressed

func _on_Button_pressed():
	emit_signal("continue_button_pressed")
	$Button.disabled = true

func reset():
	$Button.disabled = false
