extends Control



var double_bar_scene = preload("res://Scenes/UI/BasicBar/DoubleBarUI/DoubleBarUI.tscn")
var character_graph_map : Dictionary = {}

func _new_double_bar() -> DoubleBarUI:
	var double_bar_instance = double_bar_scene.instance()
	$GridContainer.columns += 1
	$GridContainer.add_child(double_bar_instance)
	return double_bar_instance

func attach_character(character : BaseCharacter):
	var double_bar : DoubleBarUI= _new_double_bar()
	character_graph_map[character] = double_bar
	character.connect("current_price_point_updated", double_bar, "set_current")
	character.connect("price_point_updated", double_bar, "set_base")
	character.connect("color_updated", double_bar, "set_color")
