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

func _ready():
	world_3d.time_scale = $TimeVSlider.value


func _on_World3D_character_created(character):
	$GraphUI.attach_character(character)
