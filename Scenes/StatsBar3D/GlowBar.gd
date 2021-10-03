extends Spatial


export(Color) var bar_color : Color = Color.white setget set_bar_color

func set_bar_color(value : Color):
	bar_color = value
	var material : SpatialMaterial = $StatsBar.get_surface_material(0)
	material = material.duplicate()
	material.albedo_color = bar_color
	$StatsBar.set_surface_material(0, material)
	
func glow_out():
	$AnimationPlayer.play("GlowOut")
