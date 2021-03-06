extends Node2D


enum CharacterLayout{RANDOM, CIRCLE, DOUBLE_CIRCLE}

var base_character_scene = preload("res://Scenes/Characters/BaseCharacter.tscn")
var character_ratio : float = 0.5
var character_count : int = 25
var character_array : Array = []
var character_layout_setting : int = CharacterLayout.CIRCLE
var center_offset : Vector2 = Vector2(960, 520.0)
var default_time_to : float = 1.0
var time_scale : float = 5.0

func get_time_to():
	if time_scale == 0.0:
		return
	return default_time_to/time_scale

func set_character_position_to_random(character : BaseCharacter):
	var new_x : float = rand_range(100.0, 1820.0)
	var new_y : float = rand_range(100.0, 980.0)
	character.move_to(Vector2(new_x, new_y), get_time_to())

func set_character_position_to_circle(character : BaseCharacter):
	var radius : float = 400.0
	var character_index = character_array.find(character)
	if character_index == -1:
		return
	var a : float = character_index * 2 * PI / character_count
	var new_vector : Vector2 = Vector2(sin(a), cos(a)) * radius + center_offset
	character.move_to(new_vector, get_time_to())

func set_character_position_to_double_circle(character : BaseCharacter):
	var radius : float = 80.0
	var radius_outer : float = 400.0
	var character_index = character_array.find(character)
	if character_index == -1:
		return
	var buyer_count = get_buyer_count()
	var character_delta = character_index
	var role_count = buyer_count
	if character_index >= buyer_count:
		radius = radius_outer
		character_delta = character_index - get_buyer_count()
		role_count = character_count - buyer_count
	var a : float = character_delta * 2 * PI / role_count
	var new_vector : Vector2 = Vector2(sin(a), cos(a)) * radius + center_offset
	character.move_to(new_vector, get_time_to())

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
	if prior_count != current_count:
		if character_layout_setting == CharacterLayout.DOUBLE_CIRCLE:
			_update_character_positions()

func _ready():
	randomize()
	for i in range(character_count):
		var character : BaseCharacter = add_character()
		if i < get_buyer_count():
			set_character_to_buyer(character)
		else:
			set_character_to_seller(character)
	$StartUpDelay.start()

func update_layout(new_layout : int):
	character_layout_setting = new_layout
	_update_character_positions()

func _update_character_positions():
	for character in character_array:
		match(character_layout_setting):
			CharacterLayout.RANDOM:
				set_character_position_to_random(character)
			CharacterLayout.CIRCLE:
				set_character_position_to_circle(character)
			CharacterLayout.DOUBLE_CIRCLE:
				set_character_position_to_double_circle(character)

func _on_StartUpDelay_timeout():
	_update_character_positions()
