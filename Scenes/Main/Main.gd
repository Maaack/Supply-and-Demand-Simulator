extends Control

onready var world_3d = $ViewportContainer/Viewport/World3D
onready var graph_world = $ViewportContainer2/Viewport/GraphWorld

func _on_World3D_character_created(character):
	var graph = graph_world.add_graph()
	if is_instance_valid(graph):
		graph.character = character
		var character_list : Array = world_3d.get_character_list()
		for iter in character_list.size():
			graph_world.assign_character_index(character_list[iter], iter)

func reset_graph_order():
	var character_list : Array = world_3d.get_character_list()
	for iter in character_list.size():
		graph_world.assign_character_index(character_list[iter], iter)

func reset_simulation():
	world_3d.target_character_count = $MenuControl.get_character_count()
	world_3d.buyer_max_price = $SettingsPanel2.buyer_max_price
	world_3d.buyer_min_price = $SettingsPanel2.buyer_min_price
	world_3d.seller_max_price = $SettingsPanel2.seller_max_price
	world_3d.seller_min_price = $SettingsPanel2.seller_min_price
	world_3d.character_ratio = $SettingsPanel2.character_ratio
	world_3d.character_layout_setting = $SettingsPanel2.character_layout
	world_3d.time_scale = $SettingsPanel2.get_speed()
	world_3d.start_sim()
	$MenuControl.hide()
	$Control.show()

func add_character():
	if is_instance_valid(world_3d):
		world_3d.add_character_and_update_positions()
		world_3d.update_character_prices()
		reset_graph_order()

func _on_MenuControl_start_button_pressed():
	reset_simulation()

func _on_SettingsPanel2_buyer_values_updated(min_value, max_value):
	if is_instance_valid(world_3d):
		world_3d.buyer_min_price = min_value
		world_3d.buyer_max_price = max_value
		world_3d.update_buyer_prices()

func _on_SettingsPanel2_character_layout_updated(value):
	if is_instance_valid(world_3d):
		world_3d.update_layout(value)

func _on_SettingsPanel2_character_ratio_updated(value):
	if is_instance_valid(world_3d):
		world_3d.update_ratio(1.0 - value)

func _on_SettingsPanel2_seller_values_updated(min_value, max_value):
	if is_instance_valid(world_3d):
		world_3d.seller_min_price = min_value
		world_3d.seller_max_price = max_value
		world_3d.update_seller_prices()

func _on_SettingsPanel2_character_added():
	add_character()

func _on_Control_mouse_entered():
	$SettingsPanel2.start_hide_timer()

func _on_SettingsPanel2_speed_updated(value):
	world_3d.time_scale = value

func _on_CloseButton_pressed():
	get_tree().quit()
