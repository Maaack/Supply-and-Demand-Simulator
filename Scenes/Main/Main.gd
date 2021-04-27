extends Control


onready var world_3d = $ViewportContainer/Viewport/World3D


func _on_HSlider_value_changed(value : float):
	world_3d.update_ratio(value / 100.0)

func _on_OneCircleButton_pressed():
	world_3d.update_layout(world_3d.CharacterLayout.CIRCLE)

func _on_TwoCirclesButton_pressed():
	world_3d.update_layout(world_3d.CharacterLayout.DOUBLE_CIRCLE)

func _on_VSlider_value_changed(value : float):
	world_3d.time_scale = value

func set_target_character_count(value : int):
	world_3d.target_character_count = value

func _ready():
	world_3d.time_scale = $Control/TimeVSlider.value
	set_target_character_count($MenuControl.get_character_count())

func _on_World3D_character_created(character):
	$ViewportContainer2/Viewport/GraphWorld.attach_character(character)

func _on_StartPanel_count_updated(value : float):
	set_target_character_count(value)

func reset_simulation():
	world_3d.target_character_count = $MenuControl.get_character_count()
	world_3d.buyer_max_price = $MenuControl.get_buyer_max_price()
	world_3d.buyer_min_price = $MenuControl.get_buyer_min_price()
	world_3d.seller_max_price = $MenuControl.get_seller_max_price()
	world_3d.seller_min_price = $MenuControl.get_seller_min_price()
	world_3d.character_ratio = $MenuControl.get_character_ratio()
	world_3d.start_sim()
	$MenuControl.hide()
	$Control.show()

func _on_MenuControl_start_button_pressed():
	reset_simulation()
