extends Spatial


const BASE_SCALE = 1.0
enum SortingType{LOWEST_FIRST, HIGHEST_FIRST}

export(float) var double_bar_x_offset : float = 1.65
export(float) var scale_mod : float = 5.0
export(int) var max_graph_count : int = 100
export(SortingType) var sorting : int = SortingType.LOWEST_FIRST

var double_bar_scene = preload("res://Scenes/StatsBar3D/DoubleStatsBar3D.tscn")
var double_bar_character_map : Dictionary = {}

func _new_double_bar() -> DoubleStatsBar3D:
	var double_bar_instance = double_bar_scene.instance()
	add_child(double_bar_instance)
	return double_bar_instance

func get_max_ratio():
	return float(double_bar_character_map.size()) / float(max_graph_count)

func scale_base_by_count(count : int):
	$StatsFlatBase3D.scale.x = float(count)

func _custom_character_sort(a : Character3D, b : Character3D):
	match(sorting):
		SortingType.LOWEST_FIRST:
			return a.price_point < b.price_point
		SortingType.HIGHEST_FIRST:
			return a.price_point > b.price_point

func get_sorted_characters():
	var characters : Array = double_bar_character_map.keys()
	characters.sort_custom(self, "_custom_character_sort")
	return characters

func reset_graph_positions():
	var iter : int = 0
	var size : int = double_bar_character_map.size()
	scale_base_by_count(size)
	var max_ratio : float = get_max_ratio()
	var total_length : float = double_bar_x_offset * size
	for character in get_sorted_characters():
		var double_bar = double_bar_character_map[character]
		var ratio = float(iter) / float(size)
		double_bar.translation.x = (ratio * total_length) - (total_length / 2) + double_bar_x_offset / 2
		double_bar.set_stat_scale((max_ratio * scale_mod) + BASE_SCALE)
		iter += 1

func _character_updated_price_point(value):
	reset_graph_positions()

func add_graph_for_character(character : Character3D):
	$StatsFlatBase3D.visible = true
	if double_bar_character_map.size() >= max_graph_count:
		return
	var double_bar : DoubleStatsBar3D = _new_double_bar()
	double_bar.character = character
	double_bar_character_map[character] = double_bar
	character.connect("price_point_updated", self, "_character_updated_price_point")
	reset_graph_positions()
	return double_bar

func remove_graph_for_character(character):
	if character in double_bar_character_map:
		var double_bar : DoubleStatsBar3D = double_bar_character_map[character]
		double_bar.queue_free()
		character.disconnect("price_point_updated", self, "_character_updated_price_point")
	var result = double_bar_character_map.erase(character)
	reset_graph_positions()
	return result
