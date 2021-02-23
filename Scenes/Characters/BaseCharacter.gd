extends Node2D


enum CharacterRoles{BUYER, SELLER}

onready var basic_bar_ui = $BasicBarUI
onready var sprite_node = $Sprite

export var buyer_color : Color
export var seller_color : Color

func _ready():
	var role : int = randi() % 2
	var price_point_mod : float = randf() * 0.9
	match role:
		CharacterRoles.BUYER:
			sprite_node.modulate = buyer_color
		CharacterRoles.SELLER:
			sprite_node.modulate = seller_color
			price_point_mod += 0.1
	var price_point : float = price_point_mod * 100
	basic_bar_ui.set_base(price_point)
	
