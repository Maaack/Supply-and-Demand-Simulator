extends Control


onready var world_2d = $ViewportContainer/Viewport/World2D

func _on_HSlider_value_changed(value : float):
	world_2d.update_ratio(value / 100.0)

func _on_CirclesButton_pressed():
	world_2d.update_layout(world_2d.CharacterLayout.DOUBLE_CIRCLE)

func _on_RandomButton_pressed():
	world_2d.update_layout(world_2d.CharacterLayout.RANDOM)
