extends Node2D


class_name BaseCharacter

signal current_price_point_updated(price)
signal price_point_updated(price)
signal color_updated(color)

enum CharacterRoles{BUYER, SELLER}

onready var basic_bar_ui = $DoubleBarUI
onready var sprite_node = $Sprite

export var buyer_color : Color
export var seller_color : Color

var character_role : int
var price_point : float
var current_price_point : float
var home_position : Vector2
var recent_transactions : Array = []

func set_home(position : Vector2):
	home_position = position

func is_home():
	return home_position == position

func set_role(value : int):
	character_role = value
	match character_role:
		CharacterRoles.BUYER:
			sprite_node.modulate = buyer_color
			basic_bar_ui.modulate = buyer_color
			emit_signal("color_updated", buyer_color)
		CharacterRoles.SELLER:
			sprite_node.modulate = seller_color
			basic_bar_ui.modulate = seller_color
			emit_signal("color_updated", seller_color)

func set_price_point(value : float):
	price_point = value
	basic_bar_ui.set_base(price_point)
	emit_signal("price_point_updated", price_point)

func set_current_price_point(value : float):
	current_price_point = value
	basic_bar_ui.set_current(current_price_point)
	emit_signal("current_price_point_updated", current_price_point)

func move_to(new_position : Vector2, time_to : float = 1.0):
	if $Tween.is_active():
		$Tween.stop_all()
	$Tween.interpolate_property(self, "position", position, new_position, time_to)
	$Tween.start()

func go_home(time_to : float = 1.0):
	move_to(home_position, time_to)

func add_transaction(avg : float = 0.0):
	recent_transactions.append(avg)

func get_avg_of_transactions():
	var sum : float = 0.0
	if recent_transactions.size() == 0:
		return sum
	for i in recent_transactions:
		sum += i
	return sum / recent_transactions.size()

func get_lower_expectations():
	return (price_point + current_price_point) / 2

func adjust_current_price_point():
	var avg = get_avg_of_transactions()
	if avg == 0.0:
		avg = get_lower_expectations()
	set_current_price_point(avg)
	recent_transactions.clear()
