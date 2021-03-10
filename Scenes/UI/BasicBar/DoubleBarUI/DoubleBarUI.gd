extends BasicBarUI


onready var progress_bar_2_node = $Node2D/ProgressBar2

func set_current(base : float):
	progress_bar_2_node.value = base

func set_base_max(base_max : float):
	progress_bar_node.max_value = base_max
	progress_bar_2_node.max_value = base_max
