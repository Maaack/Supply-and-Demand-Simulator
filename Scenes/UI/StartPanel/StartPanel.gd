extends Panel


signal count_updated(value)
signal start_button_pressed

var character_count_settings : Array = [6, 12, 25, 50, 100]
var character_count : int = 0

func character_count_by_slider_value(value : float):
	var int_value : int = int(value)
	character_count = character_count_settings[int_value]

func _ready():
	character_count_by_slider_value($CharacterCountControl/CharacterCountHSlider.value)

func _on_CharacterCountHSlider_value_changed(value):
	character_count_by_slider_value(value)
	emit_signal("count_updated", character_count)

func _on_StartButton_pressed():
	emit_signal("start_button_pressed")
