extends Node2D


class_name BaseCharacter

enum CharacterRoles{BUYER, SELLER}

onready var basic_bar_ui = $BasicBarUI
onready var sprite_node = $Sprite

export var buyer_color : Color
export var seller_color : Color

var character_role : int
var price_point : float

func set_role(value : int):
	character_role = value
	match character_role:
		CharacterRoles.BUYER:
			sprite_node.modulate = buyer_color
		CharacterRoles.SELLER:
			sprite_node.modulate = seller_color

func set_price_point(value : float):
	price_point = value
	basic_bar_ui.set_base(price_point)

func move_to(new_position : Vector2, time_to : float = 1.0):
	if $Tween.is_active():
		$Tween.seek($Tween.get_runtime())
		$Tween.stop_all()
	$Tween.interpolate_property(self, "position", position, new_position, time_to)
	$Tween.start()
