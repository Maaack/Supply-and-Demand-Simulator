extends Spatial


class_name DoubleStatsBar3D

func set_current(current : float):
	$StatsBar3D1.current_value = current

func set_base(base : float):
	$StatsBar3D2.current_value = base

func set_base_max(base_max : float):
	$StatsBar3D1.max_value = base_max
	$StatsBar3D2.max_value = base_max

func set_role(role : int):
	print("setting role as %d" % role)
	$StatsBar3D1.set_role(role)
	$StatsBar3D2.set_role(role)
