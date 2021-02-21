extends Control


onready var progress_bar_node = $Node2D/ProgressBar

func setBase(base : float):
	progress_bar_node.value = base

func setBaseMax(base_max : float):
	progress_bar_node.max_value = base_max
