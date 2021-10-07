extends Spatial


export var camera_base_size : float = 5.0
export var camera_size_mod : float = 52.0

func reset_camera_position():
	var max_ratio = max($BuyerGraph3D.get_max_ratio(), $SellerGraph3D.get_max_ratio())
	$Spatial/Camera.size = int((camera_size_mod * max_ratio) + camera_base_size)

func add_graph_for_character(character : Character3D):
	character.connect("role_updated", self, "update_graphs_for_character", [character])

func update_graphs_for_character(character_role : int, character : Character3D):
	var graph = null
	match(character_role):
		Character3D.CharacterRoles.BUYER:
			$SellerGraph3D.remove_graph_for_character(character)
			$BuyerGraph3D.show()
			graph = $BuyerGraph3D.add_graph_for_character(character)
		Character3D.CharacterRoles.SELLER:
			$BuyerGraph3D.remove_graph_for_character(character)
			$SellerGraph3D.show()
			graph = $SellerGraph3D.add_graph_for_character(character)
	reset_camera_position()
