extends Spatial


class_name Character3D

signal current_price_point_updated(price)
signal price_point_updated(price)
signal color_updated(color)

enum CharacterRoles{BUYER, SELLER}

export var buyer_color : Color
export var seller_color : Color

var character_role : int
var price_point : float
var current_price_point : float
var home_position : Vector3
var recent_transactions : Array = []
var all_transactions : Array = []

func set_home(position : Vector3):
	home_position = position

func is_home():
	return home_position == translation

func set_role(value : int):
	character_role = value
	match character_role:
		CharacterRoles.BUYER:
			$SellerCharacter.visible = false
			$BuyerCharacter.visible = true
			emit_signal("color_updated", buyer_color)
		CharacterRoles.SELLER:
			$BuyerCharacter.visible = false
			$SellerCharacter.visible = true
			emit_signal("color_updated", seller_color)

func set_price_point(value : float):
	price_point = value
	reset_history()
	emit_signal("price_point_updated", price_point)

func set_current_price_point(value : float):
	current_price_point = value
	emit_signal("current_price_point_updated", current_price_point)

func move_to(new_translation : Vector3, time_to : float = 1.0):
	if $Tween.is_active():
		$Tween.stop_all()
	$Tween.interpolate_property(self, "translation", translation, new_translation, time_to)
	$Tween.start()

func go_home(time_to : float = 1.0):
	move_to(home_position, time_to)

func add_transaction(avg : float = 0.0):
	recent_transactions.append(avg)

func get_avg_of_array(values : Array):
	var sum : float = 0.0
	if values.size() == 0:
		return sum
	for i in values:
		sum += i
	return sum / values.size()

func get_avg_of_all_transactions():
	return get_avg_of_array(all_transactions)

func get_avg_of_recent_transactions():
	return get_avg_of_array(recent_transactions)

func get_lower_expectations():
	return (price_point + current_price_point) / 2

func adjust_current_price_point():
	var avg : float = get_avg_of_recent_transactions()
	if avg == 0.0:
		avg = get_lower_expectations()
	var lifetime_avg : float = get_avg_of_all_transactions()
	if lifetime_avg != 0.0:
		avg = (avg + lifetime_avg) / 2.0
	set_current_price_point(avg)
	all_transactions += recent_transactions
	recent_transactions.clear()

func reset_history():
	all_transactions.clear()
	recent_transactions.clear()
	current_price_point = price_point
