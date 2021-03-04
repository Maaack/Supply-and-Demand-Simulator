extends Node2D


var base_character_scene = preload("res://Scenes/Characters/BaseCharacter.tscn")
var character_ratio : float = 0.5
var character_count : int = 10
var character_array : Array = []

func set_character_position_to_random(character : BaseCharacter):
	var new_x : float = rand_range(100.0, 924.0)
	var new_y : float = rand_range(100.0, 500.0)
	character.move_to(Vector2(new_x, new_y))

func set_character_position_to_circle(character : BaseCharacter):
	var character_index = character_array.find(character)
	if character_index == -1:
		return
	var a : float = character_index * 2 * PI / character_count
	var new_x : float = sin(a) * 300.0 + 512.0
	var new_y : float = cos(a) * 300.0 + 300.0
	character.move_to(Vector2(new_x, new_y))

func add_character():
	var base_character_instance : BaseCharacter = base_character_scene.instance()
	add_child(base_character_instance)
	set_character_position_to_random(base_character_instance)
	character_array.append(base_character_instance)
	return base_character_instance

func get_buyer_count():
	return round(character_count * character_ratio)

func set_character_to_buyer(character : BaseCharacter):
	character.set_role(BaseCharacter.CharacterRoles.BUYER)

func set_character_to_seller(character : BaseCharacter):
	character.set_role(BaseCharacter.CharacterRoles.SELLER)
	
func update_ratio(value : float):
	var prior_count : int = get_buyer_count()
	character_ratio = value
	var current_count : int = get_buyer_count()
	if current_count > prior_count:
		for i in range(prior_count, current_count):
			var current_character : BaseCharacter = character_array[i]
			if is_instance_valid(current_character):
				set_character_to_buyer(current_character)
	elif current_count < prior_count:
		for i in range(current_count, prior_count):
			var current_character : BaseCharacter = character_array[i]
			if is_instance_valid(current_character):
				set_character_to_seller(current_character)

func _ready():
	randomize()
	for i in range(character_count):
		var character : BaseCharacter = add_character()
		if i < get_buyer_count():
			set_character_to_buyer(character)
		else:
			set_character_to_seller(character)
	$StartUpDelay.start()

func _on_StartUpDelay_timeout():
	for character in character_array:
		set_character_position_to_circle(character)
