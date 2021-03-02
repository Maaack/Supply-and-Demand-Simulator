extends Control


onready var world_2d = $ViewportContainer/Viewport/World2D

func _on_HSlider_value_changed(value : float):
	world_2d.update_ratio(value / 100.0)
