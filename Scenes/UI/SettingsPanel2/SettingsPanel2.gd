extends Panel


signal character_layout_updated(value)
signal character_ratio_updated(value)
signal buyer_values_updated(min_value, max_value)
signal seller_values_updated(min_value, max_value)
signal character_added
signal toggle_activated

enum LayoutSettings{ONE_CIRCLE, TWO_CIRCLES}
export(float, 0.0, 1.0) var character_ratio : float = 0.5
export(float, 0.0, 1.0) var buyer_min_price : float = 0.2
export(float, 0.0, 1.0) var buyer_max_price : float = 1.0
export(float, 0.0, 1.0) var seller_min_price : float = 0.0
export(float, 0.0, 1.0) var seller_max_price : float = 0.8
export(LayoutSettings) var character_layout : int = 0

onready var buyer_slider_1 = $MarginContainer/HBoxContainer/VBoxContainer/BuyerSlider1
onready var buyer_slider_2 = $MarginContainer/HBoxContainer/VBoxContainer/BuyerSlider2
onready var seller_slider_1 = $MarginContainer/HBoxContainer/VBoxContainer2/SellerSlider1
onready var seller_slider_2 = $MarginContainer/HBoxContainer/VBoxContainer2/SellerSlider2
onready var ratio_slider = $MarginContainer/HBoxContainer/VBoxContainer/RatioSlider
onready var layout_button = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/LayoutButton

var ready : bool = false
var activated : bool = false

func init_values():
	buyer_slider_1.value = int(buyer_min_price * 100.0)
	buyer_slider_2.value = int(buyer_max_price * 100.0)
	seller_slider_1.value = int(seller_min_price * 100.0)
	seller_slider_2.value = int(seller_max_price * 100.0)
	ratio_slider.value = int(character_ratio * 100.0)
	layout_button.selected = character_layout

func update_buyer_values():
	var buyer_price_1 = float(buyer_slider_1.value) / 100.0
	var buyer_price_2 = float(buyer_slider_2.value) / 100.0
	buyer_min_price = min(buyer_price_1, buyer_price_2)
	buyer_max_price = max(buyer_price_1, buyer_price_2)
	emit_signal("buyer_values_updated", buyer_min_price, buyer_max_price)

func update_seller_values():
	var seller_price_1 = float(seller_slider_1.value) / 100.0
	var seller_price_2 = float(seller_slider_2.value) / 100.0
	seller_min_price = min(seller_price_1, seller_price_2)
	seller_max_price = max(seller_price_1, seller_price_2)
	emit_signal("seller_values_updated", seller_min_price, seller_max_price)

func update_ratio():
	character_ratio = float(ratio_slider.value) / 100.0
	emit_signal("character_ratio_updated", character_ratio)

func update_character_layout():
	character_layout = layout_button.selected
	emit_signal("character_layout_updated", character_layout)

func _ready():
	init_values()
	ready = true

func _on_BuyerSlider1_value_changed(value):
	if ready:
		update_buyer_values()

func _on_BuyerSlider2_value_changed(value):
	if ready:
		update_buyer_values()

func _on_SellerSlider1_value_changed(value):
	if ready:
		update_seller_values()

func _on_SellerSlider2_value_changed(value):
	if ready:
		update_seller_values()

func _on_RatioSlider_value_changed(value):
	if ready:
		update_ratio()

func _on_LayoutButton_item_selected(index):
	if ready:
		update_character_layout()

func _on_Button_pressed():
	if ready:
		emit_signal("character_added")

func _on_ToggleButton_mouse_entered():
	if not activated:
		activated = true
		$AnimationPlayer.play("SettingsPanel2MoveUp")
		emit_signal("toggle_activated")

func _on_HideDelayTimer_timeout():
	$AnimationPlayer.play("SettingsPanel2MoveDown")
	activated = false

func _on_SettingsPanel2_mouse_entered():
	$HideDelayTimer.stop()

func start_hide_timer():
	if activated:
		$HideDelayTimer.start()
