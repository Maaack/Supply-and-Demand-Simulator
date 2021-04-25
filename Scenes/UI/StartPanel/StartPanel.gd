extends Panel


signal count_updated(value)
signal start_button_pressed

export(int, 2, 100) var character_count : int = 25
export(float, 0.0, 1.0) var character_ratio : float = 0.5
export(float, 0.0, 1.0) var buyer_lowest_price : float = 0.2
export(float, 0.0, 1.0) var buyer_highest_price : float = 1.0
export(float, 0.0, 1.0) var seller_lowest_price : float = 0.0
export(float, 0.0, 1.0) var seller_highest_price : float = 0.8

func init_values():
	$CharacterCountControl/CharacterCountLabel/SpinBox.get_line_edit().text = "%3d" % (character_count)
	$CharacterCountControl/MinBuyerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (buyer_lowest_price * 100.0)
	$CharacterCountControl/MaxBuyerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (buyer_highest_price * 100.0)
	$CharacterCountControl/MinSellerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (seller_lowest_price * 100.0)
	$CharacterCountControl/MaxSellerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (seller_highest_price * 100.0)
	$CharacterCountControl/BuyerSellerRatioLabel/HSlider.value = character_ratio * 100.0

func update_values():
	character_count = int($CharacterCountControl/CharacterCountLabel/SpinBox.get_line_edit().text)
	buyer_lowest_price = float($CharacterCountControl/MinBuyerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	buyer_highest_price = float($CharacterCountControl/MaxBuyerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	seller_lowest_price = float($CharacterCountControl/MinSellerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	seller_highest_price = float($CharacterCountControl/MaxSellerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	character_ratio = $CharacterCountControl/BuyerSellerRatioLabel/HSlider.value / 100.0

func _on_StartButton_pressed():
	update_values()
	emit_signal("start_button_pressed")

func _ready():
	init_values()
