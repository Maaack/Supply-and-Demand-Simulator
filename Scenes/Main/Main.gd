extends Node2D


var base_character_scene = preload("res://Scenes/Characters/BaseCharacter.tscn")

func add_random_character():
	var base_character_instance : Node2D = base_character_scene.instance()
	add_child(base_character_instance)
	var new_x : float = rand_range(100.0, 924.0)
	var new_y : float = rand_range(100.0, 500.0)
	base_character_instance.position = Vector2(new_x, new_y)


func _ready():
	randomize()
	for i in range(10):
		add_random_character()
