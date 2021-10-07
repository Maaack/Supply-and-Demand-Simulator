extends Spatial


signal character_created(character)

enum CharacterLayout{CIRCLE, DOUBLE_CIRCLE}

onready var travel_phase = $PhaseManager/Travel
onready var trade_phase = $PhaseManager/Trade
onready var return_phase = $PhaseManager/Return
onready var adjust_phase = $PhaseManager/Adjust

export(float, 0.25, 64) var time_scale : float = 1.0
export(CharacterLayout) var character_layout_setting : int = CharacterLayout.CIRCLE
export(int, 5, 50) var target_character_count : int = 25
export(float, 0.0, 1.0) var character_ratio : float = 0.5
export(float, 0.0, 1.0) var buyer_min_price : float = 0.0
export(float, 0.0, 1.0) var buyer_max_price : float = 1.0
export(float, 0.0, 1.0) var seller_min_price : float = 0.0
export(float, 0.0, 1.0) var seller_max_price : float = 1.0
export(float, 0.0, 1.0) var character_limit : float = 50

var character_scene = preload("res://Scenes/Characters3D/Character3D.tscn")
var character_array : Array = []
var buyers_array : Array = []
var sellers_array : Array = []
var character_iter : int = 0
var buyers_iter : int = 0
var sellers_iter : int = 0
var default_time_to : float = 0.35
var default_step_time : float = 0.35
var buyer_seller_map : Dictionary = {}
var seller_return_map : Dictionary = {}
var active_character : Character3D
var time_mod : float = 1.0

func get_time_to():
	if time_scale == 0.0:
		return
	return default_time_to/time_scale

func _set_character_home_position_to_circle(character : Character3D, index : int):
	var radius : float = 40.0
	var a : float = index * 2 * PI / target_character_count
	var new_vector : Vector3 = Vector3(sin(a), 0, cos(a)) * radius 
	character.set_home(new_vector)

func _set_character_home_position_to_double_circle(character : Character3D, index : int):
	var radius : float = 15.0
	var radius_outer : float = 40.0
	var buyer_count = get_target_buyer_count()
	var character_delta = index
	var role_count = buyer_count
	if index >= buyer_count:
		radius = radius_outer
		character_delta = index - buyer_count
		role_count = target_character_count - buyer_count
	var a : float = character_delta * 2 * PI / role_count
	var new_vector : Vector3 = Vector3(sin(a), 0, cos(a)) * radius
	character.set_home(new_vector)

func get_character_list() -> Array:
	return buyers_array + sellers_array

func _add_character():
	if character_array.size() >= character_limit:
		return false
	var character_instance = character_scene.instance()
	add_child(character_instance)
	character_array.append(character_instance)
	emit_signal("character_created", character_instance)
	return character_instance

func add_buyer():
	var character = _add_character()
	buyers_array.append(character)
	character.set_role(Character3D.CharacterRoles.BUYER)
	return character

func add_seller():
	var character = _add_character()
	sellers_array.append(character)
	character.set_role(Character3D.CharacterRoles.SELLER)
	return character

func get_target_buyer_count():
	return int(round(target_character_count * character_ratio))

func get_buyer_count():
	return buyers_array.size()
	
func get_seller_count():
	return sellers_array.size()

func add_character():
	if character_array.size() >= character_limit:
		return false
	var character : Character3D
	var character_count : int = character_array.size() + 1
	if character_count > target_character_count:
		target_character_count = character_count
	if get_buyer_count() < get_target_buyer_count():
		character = add_buyer()
	else:
		character = add_seller()
	return character

func add_character_and_update_positions():
	var character = add_character()
	_update_character_positions()
	return character

func swap_to_role(role : int):
	var character : Character3D
	var index : int
	match role:
		Character3D.CharacterRoles.BUYER:
			character = sellers_array.pop_front()
			buyers_array.push_back(character)
			index = buyers_array.size() - 1
		Character3D.CharacterRoles.SELLER:
			character = buyers_array.pop_back()
			sellers_array.push_front(character)
			index = buyers_array.size()
	if not character is Character3D:
		return
	character.set_role(role)
	_update_character_home_position(character, index)
	character.go_home()

func update_ratio(value : float):
	var prior_count : int = get_target_buyer_count()
	character_ratio = value
	var current_count : int = get_target_buyer_count()
	if current_count > prior_count:
		for i in range(current_count - prior_count):
			swap_to_role(Character3D.CharacterRoles.BUYER)
	elif current_count < prior_count:
		for i in range(prior_count - current_count):
			swap_to_role(Character3D.CharacterRoles.SELLER)
	if prior_count != current_count:
		update_character_prices()
		_update_character_positions()

func _ready():
	randomize()

func update_layout(new_layout : int):
	character_layout_setting = new_layout
	_update_character_positions()

func _update_character_home_position(character, index):
	match(character_layout_setting):
		CharacterLayout.CIRCLE:
			_set_character_home_position_to_circle(character, index)
		CharacterLayout.DOUBLE_CIRCLE:
			_set_character_home_position_to_double_circle(character, index)

func _update_character_home_position_and_move(character : Character3D, iter : int):
		_update_character_home_position(character, iter)
		character.move_to_current_target(get_time_to())

func _update_character_positions():
	for iter in sellers_array.size():
		var position_iter = iter + buyers_array.size()
		_update_character_home_position_and_move(sellers_array[iter], position_iter)
	for iter in buyers_array.size():
		_update_character_home_position_and_move(buyers_array[iter], iter)

func update_buyer_prices():
	var buyer_price_iter : int = 0
	var ratio : float
	var amount : float
	for character in buyers_array:
		if buyers_array.size() < 2:
			ratio = 0.5
		else:
			ratio = float(buyer_price_iter) / float(buyers_array.size() - 1)
		amount = ((ratio * (buyer_max_price - buyer_min_price)) + buyer_min_price) * 100.0
		buyer_price_iter += 1
		character.set_price_point(amount)
		character.set_current_price_point(amount)

func update_seller_prices():
	var seller_price_iter : int = 0
	var ratio : float
	var amount : float
	for character in sellers_array:
		if sellers_array.size() < 2:
			ratio = 0.5
		else:
			ratio = float(seller_price_iter) / float(sellers_array.size() - 1)
		amount = ((ratio * (seller_max_price - seller_min_price)) + seller_min_price) * 100.0
		seller_price_iter += 1
		character.set_price_point(amount)
		character.set_current_price_point(amount)

func update_character_prices():
	update_buyer_prices()
	update_seller_prices()

func _update_simulate_step_time():
	$SimulateStep.wait_time = default_step_time / (time_scale * time_mod)

func _increment_characters():
	var character_list : Array = get_character_list()
	if character_iter < character_list.size():
		character_iter += 1
		if character_iter < character_list.size():
			active_character = character_list[character_iter]
			return false
	character_iter = 0
	active_character = character_list[character_iter]
	return true

func _increment_buyers_only():
	if buyers_iter < get_buyer_count():
		buyers_iter += 1
		if buyers_iter < get_buyer_count():
			active_character = buyers_array[buyers_iter]
			return false
	buyers_iter = 0
	if buyers_iter < get_buyer_count():
		active_character = buyers_array[buyers_iter]
	else:
		active_character = null
	return true

func do_transaction(buyer : Character3D, seller : Character3D):
	seller.face_to(buyer.translation, get_time_to())
	if buyer.current_price_point >= seller.current_price_point:
		var avg : float = (buyer.current_price_point + seller.current_price_point) / 2.0
		buyer.add_transaction(avg)
		seller.add_transaction(avg)
		buyer.add_item(Character3D.ItemTypes.APPLE)
		seller.add_item(Character3D.ItemTypes.COINS)
		return true
	else:
		buyer.no_item()
	return false

func _next_travel_cycle():
	if is_instance_valid(active_character) and active_character.is_buyer():
		if sellers_array.size() == 0:
			return false
		var random_seller_i = randi() % sellers_array.size()
		var random_seller = sellers_array[random_seller_i]
		buyer_seller_map[active_character] = random_seller
		active_character.go_to_character(random_seller, get_time_to())
	return _increment_buyers_only()

func _next_trade_cycle():
	while(is_instance_valid(active_character) and active_character.is_home()):
		if _increment_buyers_only():
			return true
	if is_instance_valid(active_character) and active_character in buyer_seller_map:
		do_transaction(active_character, buyer_seller_map[active_character])
		buyer_seller_map.erase(active_character)
	return _increment_buyers_only()

func _next_return_cycle():
	while(is_instance_valid(active_character) and active_character.is_home()):
		if _increment_buyers_only():
			return true
	if is_instance_valid(active_character):
		active_character.go_home(get_time_to())
	return _increment_buyers_only()

func _next_adjust_cycle():
	if is_instance_valid(active_character):
		active_character.adjust_current_price_point()
	return _increment_characters()

func _next_step():
	var advance_phase_flag : bool = false
	match($PhaseManager.current_phase):
		travel_phase:
			advance_phase_flag = _next_travel_cycle()
		trade_phase:
			advance_phase_flag = _next_trade_cycle()
		return_phase:
			advance_phase_flag = _next_return_cycle()
		adjust_phase:
			advance_phase_flag = _next_adjust_cycle()
	if advance_phase_flag:
		$PhaseManager.advance()

func start_sim_phases():
	active_character = character_array[0]
	update_character_prices()
	_update_character_positions()
	_update_simulate_step_time()
	$PhaseManager.advance()
	$SimulateStep.start()

func _on_SimulateStep_timeout():
	_update_simulate_step_time()
	_next_step()

func _on_SpawnDelay_timeout():
	var character = add_character()
	_update_character_home_position_and_move(character, character_array.size() - 1)
	if character_array.size() < target_character_count:
		$SpawnDelay.start()
	else:
		start_sim_phases()

func start_sim():
	$SpawnDelay.start()

func _on_Adjust_phase_entered():
	time_mod = 2.0
	_update_simulate_step_time()

func _on_Travel_phase_entered():
	time_mod = 1.0
	_update_simulate_step_time()
