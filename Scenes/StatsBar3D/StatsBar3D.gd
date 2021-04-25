extends Spatial


enum CharacterRoles{BUYER, SELLER}
enum StatsType{MATTE, METAL}

export(CharacterRoles) var character_role : int
export(StatsType) var stats_type : int

var buyer_metal_material = preload("res://Assets/Originals/gltf/BuyerStatsBar2.material")
var buyer_matte_material = preload("res://Assets/Originals/gltf/BuyerStatsBar.material")
var seller_metal_material = preload("res://Assets/Originals/gltf/SellerStatsBar2.material")
var seller_matte_material = preload("res://Assets/Originals/gltf/SellerStatsBar.material")
var max_value : float = 100.0
var current_value : float = 100.0 setget set_value
var full_size : float = 2.8
var stats_bar_top_offset : Vector3 = Vector3(0.0, 0.015, 0.0)

func update_material():
	var material
	match character_role:
		CharacterRoles.BUYER:
			match stats_type:
				StatsType.MATTE:
					material = buyer_matte_material
				StatsType.METAL:
					material = buyer_metal_material
		CharacterRoles.SELLER:
			match stats_type:
				StatsType.MATTE:
					material = seller_matte_material
				StatsType.METAL:
					material = seller_metal_material
	$StatsBarSpatial/StatsBar/StatsBar.set_surface_material(0, material)
	$StatsBarTop/StatsBar003.set_surface_material(0, material)

func set_role(value : int):
	character_role = value
	update_material()

func set_type(value : int):
	stats_type = value
	update_material()

func set_value(value : float):
	if current_value != value:
		current_value = value
		var scale_ratio = current_value / max_value
		$StatsBarSpatial.scale.y = scale_ratio
		$StatsBarTop.translation.y = (scale_ratio * full_size) + stats_bar_top_offset.y

func _ready():
	update_material()
