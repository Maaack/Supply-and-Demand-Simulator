tool
extends Spatial


enum CharacterRoles{BUYER, SELLER}
enum StatsType{MATTE, METAL}

export(CharacterRoles) var character_role : int
export(StatsType) var stats_type : int
export(float) var glow_amount : float

var buyer_metal_material = preload("res://Assets/Originals/gltf/BuyerStatsBar2.material")
var buyer_matte_material = preload("res://Assets/Originals/gltf/BuyerStatsBar.material")
var seller_metal_material = preload("res://Assets/Originals/gltf/SellerStatsBar2.material")
var seller_matte_material = preload("res://Assets/Originals/gltf/SellerStatsBar.material")
var max_value : float = 100.0
var current_value : float = 100.0 setget set_value
var full_size : float = 2.8
var stat_scale : float = 1.0
var stats_bar_top_offset : Vector3 = Vector3(0.0, 0.015, 0.0)

func update_material():
	var material : SpatialMaterial
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
	$StatsBar/StatsBar.set_surface_material(0, material)
	$StatsBarTop/StatsBar003.set_surface_material(0, material)

func set_role(value : int):
	character_role = value
	update_material()

func set_type(value : int):
	stats_type = value
	update_material()

func set_value(value : float):
	current_value = value
	var scale_ratio = current_value / max_value
	var final_scale_y = scale_ratio * stat_scale
	if final_scale_y != $StatsBar.scale.y:
		$StatsBar.scale.y = final_scale_y
		$GlowBar.scale.y = final_scale_y
		$StatsBarTop.translation.y = (scale_ratio * full_size * stat_scale) + stats_bar_top_offset.y
		$GlowBarTop.translation.y = $StatsBarTop.translation.y
		$GlowBar.glow_out()
		$GlowBarTop.glow_out()

func _ready():
	update_material()
