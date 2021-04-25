extends Spatial


export var double_bar_x_offset : float = 1.6
export var camera_base_size : float = 5.0
export var camera_max_size : float = 100.0
export var max_graph_count : int = 100

var double_bar_scene = preload("res://Scenes/StatsBar3D/DoubleStatsBar3D.tscn")
var character_graph_map : Dictionary = {}

func _new_double_bar() -> DoubleStatsBar3D:
	var double_bar_instance = double_bar_scene.instance()
	add_child(double_bar_instance)
	return double_bar_instance

func reset_graph_positions():
	var iter : int = 0
	var size : int = character_graph_map.size()
	$StatsFlatBase3D.scale.x = float(size)
	var total_length : float = double_bar_x_offset * size
	for double_bar in character_graph_map.values():
		var ratio = float(iter) / float(size)
		double_bar.translation.x = (ratio * total_length) - (total_length / 2) + double_bar_x_offset / 2
		iter += 1
	var max_ratio : float = float(size) / float(max_graph_count)
	$Spatial/Camera.size = int((camera_max_size - camera_base_size) * max_ratio + camera_base_size)

func attach_character(character : Character3D):
	if character_graph_map.size() >= max_graph_count:
		return
	var double_bar : DoubleStatsBar3D = _new_double_bar()
	character_graph_map[character] = double_bar
	double_bar.set_role(character.character_role)
	character.connect("current_price_point_updated", double_bar, "set_current")
	character.connect("price_point_updated", double_bar, "set_base")
	character.connect("role_updated", double_bar, "set_role")
	reset_graph_positions()

