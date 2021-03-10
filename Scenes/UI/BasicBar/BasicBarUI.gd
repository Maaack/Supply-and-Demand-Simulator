extends Control


class_name BasicBarUI

onready var progress_bar_node = $Node2D/ProgressBar

func set_base(base : float):
	progress_bar_node.value = base

func set_base_max(base_max : float):
	progress_bar_node.max_value = base_max
