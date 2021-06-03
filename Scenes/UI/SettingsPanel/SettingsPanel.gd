extends Panel


signal count_updated(value)
signal start_button_pressed

enum LayoutSettings{ONE_CIRCLE, TWO_CIRCLES}
export(int, 2, 100) var character_count : int = 25
export(float, 0.0, 1.0) var character_ratio : float = 0.5
export(float, 0.0, 1.0) var buyer_min_price : float = 0.2
export(float, 0.0, 1.0) var buyer_max_price : float = 1.0
export(float, 0.0, 1.0) var seller_min_price : float = 0.0
export(float, 0.0, 1.0) var seller_max_price : float = 0.8
export(LayoutSettings) var character_layout : int = 0

func init_values():
	$MarginContainer/VBoxContainer/CharacterCountLabel/SpinBox.value = character_count

func update_values():
	character_count = int($MarginContainer/VBoxContainer/CharacterCountLabel/SpinBox.value)

func _on_StartButton_pressed():
	update_values()
	emit_signal("start_button_pressed")

func _ready():
	init_values()
