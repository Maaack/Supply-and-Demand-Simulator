extends Panel


signal count_updated(value)
signal start_button_pressed

export(int, 2, 100) var character_count : int = 25
export(float, 0.0, 1.0) var character_ratio : float = 0.5
export(float, 0.0, 1.0) var buyer_min_price : float = 0.2
export(float, 0.0, 1.0) var buyer_max_price : float = 1.0
export(float, 0.0, 1.0) var seller_min_price : float = 0.0
export(float, 0.0, 1.0) var seller_max_price : float = 0.8

func init_values():
	$MenuControl/CharacterCountLabel/SpinBox.get_line_edit().text = "%3d" % (character_count)
	$MenuControl/MinBuyerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (buyer_min_price * 100.0)
	$MenuControl/MaxBuyerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (buyer_max_price * 100.0)
	$MenuControl/MinSellerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (seller_min_price * 100.0)
	$MenuControl/MaxSellerPriceLabel/SpinBox.get_line_edit().text = "%3.f" % (seller_max_price * 100.0)
	$MenuControl/BuyerSellerRatioLabel/HSlider.value = character_ratio * 100.0

func update_values():
	var buyer_price_1 = float($MenuControl/MinBuyerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	var buyer_price_2 = float($MenuControl/MaxBuyerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	buyer_min_price = min(buyer_price_1, buyer_price_2)
	buyer_max_price = max(buyer_price_1, buyer_price_2)
	character_count = int($MenuControl/CharacterCountLabel/SpinBox.get_line_edit().text)
	var seller_price_1 = float($MenuControl/MinSellerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	var seller_price_2 = float($MenuControl/MaxSellerPriceLabel/SpinBox.get_line_edit().text) / 100.0
	seller_min_price = min(seller_price_1, seller_price_2)
	seller_max_price = max(seller_price_1, seller_price_2)
	character_ratio = $MenuControl/BuyerSellerRatioLabel/HSlider.value / 100.0

func _on_StartButton_pressed():
	update_values()
	emit_signal("start_button_pressed")

func _ready():
	init_values()
