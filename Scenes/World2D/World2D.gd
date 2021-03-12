extends Node2D


enum CharacterLayout{CIRCLE, DOUBLE_CIRCLE}

onready var travel_phase = $PhaseManager/Travel
onready var return_phase = $PhaseManager/Return
onready var adjust_phase = $PhaseManager/Adjust

var base_character_scene = preload("res://Scenes/Characters/BaseCharacter.tscn")
var character_ratio : float = 0.5
var character_count : int = 25
var character_array : Array = []
var character_layout_setting : int = CharacterLayout.CIRCLE
var default_time_to : float = 1.0
var time_scale : float = 1.0
var default_step_time : float = 1.0
var character_control_counter : int = 0
var buyer_seller_map : Dictionary = {}

func get_time_to():
	if time_scale == 0.0:
		return
	return default_time_to/time_scale


func set_character_position_to_circle(character : BaseCharacter):
	var radius : float = 400.0
	var character_index = character_array.find(character)
	if character_index == -1:
		return
	var a : float = character_index * 2 * PI / character_count
	var new_vector : Vector2 = Vector2(sin(a), cos(a)) * radius
	character.set_home(new_vector)

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
	var new_vector : Vector2 = Vector2(sin(a), cos(a)) * radius
	character.set_home(new_vector)

func add_character():
	var base_character_instance : BaseCharacter = base_character_scene.instance()
	add_child(base_character_instance)
	character_array.append(base_character_instance)
	return base_character_instance

func get_buyer_count():
	return int(round(character_count * character_ratio))

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
		_update_character_prices()
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
	_update_character_prices()
	$StartUpDelay.start()

func update_layout(new_layout : int):
	character_layout_setting = new_layout
	_update_character_positions()

func _update_character_positions():
	for character in character_array:
		match(character_layout_setting):
			CharacterLayout.CIRCLE:
				set_character_position_to_circle(character)
			CharacterLayout.DOUBLE_CIRCLE:
				set_character_position_to_double_circle(character)
		character.go_home(get_time_to())

func _update_character_prices():
	var buyer_count : int = get_buyer_count()
	var i : int = 0
	var total : int = buyer_count
	for character in character_array:
		if i >= total:
			i -= buyer_count
			total = character_count - buyer_count
		var amount : float = 100.0 * float(i) / float(total)
		character.set_price_point(amount)
		character.set_current_price_point(amount)
		i += 1

func _on_StartUpDelay_timeout():
	_update_character_positions()
	$PhaseManager.advance()
	$SimulateStep.start()

func get_buying_position(buyer : BaseCharacter, seller : BaseCharacter, buy_distance : float = 50.0):
	var delta_vector : Vector2 = seller.position - buyer.position
	var buy_vector = delta_vector.normalized() * buy_distance
	return delta_vector - buy_vector + buyer.position

func _update_simulate_step_time():
	$SimulateStep.wait_time = default_step_time / time_scale

func _cycle_seller(seller : BaseCharacter):
	if seller.character_role != BaseCharacter.CharacterRoles.SELLER:
		print("%s not a seller." % str(seller))
		return
	match($PhaseManager.current_phase):
		adjust_phase:
			seller.adjust_current_price_point()

func _increment_characters():
	character_control_counter += 1
	if character_control_counter >= character_count:
		character_control_counter = 0
		return true
	return false

func _increment_sellers_only():
	character_control_counter += 1
	if character_control_counter >= get_buyer_count():
		character_control_counter = 0
		return true
	return false

func do_transaction(buyer : BaseCharacter, seller : BaseCharacter):
	if buyer.current_price_point >= seller.current_price_point:
		var avg : float = (buyer.current_price_point + seller.current_price_point) / 2.0
		buyer.add_transaction(avg)
		seller.add_transaction(avg)
		return true
	return false

func _next_travel_cycle():
	var current_character : BaseCharacter = character_array[character_control_counter]
	if current_character.character_role == BaseCharacter.CharacterRoles.BUYER:
		var buyer_count = get_buyer_count()
		var seller_count = character_count - buyer_count
		var random_seller_i = randi() % seller_count + buyer_count
		var random_seller = character_array[random_seller_i]
		buyer_seller_map[current_character] = random_seller
		var buy_position = get_buying_position(current_character, random_seller)
		current_character.move_to(buy_position, get_time_to())
	return _increment_sellers_only()

func _next_return_cycle():
	var current_character : BaseCharacter = character_array[character_control_counter]
	if current_character.character_role == BaseCharacter.CharacterRoles.BUYER:
		if current_character in buyer_seller_map:
			do_transaction(current_character, buyer_seller_map[current_character])
			buyer_seller_map.erase(current_character)
		current_character.go_home(get_time_to())
	return _increment_sellers_only()

func _next_adjust_cycle():
	var current_character : BaseCharacter = character_array[character_control_counter]
	current_character.adjust_current_price_point()
	return _increment_characters()

func _next_step():
	var advance_phase_flag : bool = false
	match($PhaseManager.current_phase):
		travel_phase:
			advance_phase_flag = _next_travel_cycle()
		return_phase:
			advance_phase_flag = _next_return_cycle()
		adjust_phase:
			advance_phase_flag = _next_adjust_cycle()
	if advance_phase_flag:
		$PhaseManager.advance()

func _on_SimulateStep_timeout():
	_update_simulate_step_time()
	_next_step()
