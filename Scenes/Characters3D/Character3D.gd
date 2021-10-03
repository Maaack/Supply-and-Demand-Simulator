extends Spatial


class_name Character3D

signal current_price_point_updated(price)
signal price_point_updated(price)
signal role_updated(role)

enum CharacterRoles{BUYER, SELLER}
enum ItemTypes{APPLE, COINS}
enum MoveTarget{NONE, HOME, CHARACTER}

export var buyer_color : Color
export var seller_color : Color
export var prefilled_price_points : int = 3

onready var buyer_character = $CharacterSpatial/BuyerCharacter
onready var seller_character = $CharacterSpatial/SellerCharacter
onready var character_spatial = $CharacterSpatial
onready var apple_item = $ItemControl/Apple
onready var coins_item = $ItemControl/Coins
onready var no_item = $ItemControl/CrossOut

var character_role : int
var price_point : float
var current_price_point : float
var home_position : Vector3
var target_position : Vector3
var going_to : int = MoveTarget.HOME
var recent_transactions : Array = []
var all_transactions : Array = []
var character_target = null

func set_home(position : Vector3):
	home_position = position

func is_home():
	return home_position == translation

func is_buyer():
	return character_role == CharacterRoles.BUYER

func is_seller():
	return character_role == CharacterRoles.SELLER

func set_role(value : int):
	character_role = value
	match character_role:
		CharacterRoles.BUYER:
			seller_character.visible = false
			buyer_character.visible = true
		CharacterRoles.SELLER:
			buyer_character.visible = false
			seller_character.visible = true
	emit_signal("role_updated", character_role)

func set_price_point(value : float):
	price_point = value
	reset_history()
	emit_signal("price_point_updated", price_point)

func set_current_price_point(value : float):
	current_price_point = value
	emit_signal("current_price_point_updated", current_price_point)

func get_angle_on_y_axis(translation_to_face : Vector3):
	var cross : Vector3 = Vector3.FORWARD.cross(translation_to_face).normalized()
	var angle : float = Vector3.FORWARD.angle_to(translation_to_face)
	if cross.y > 0:
		angle *= -1.0
	return angle

func face_to(new_translation : Vector3, time_to : float = 1.0):
	var vector_mask : Vector3 = Vector3.FORWARD + Vector3.RIGHT
	var new_masked_translation : Vector3 = (new_translation - translation) * vector_mask
	var angle = get_angle_on_y_axis(new_masked_translation)
	$Tween.interpolate_property(character_spatial, "rotation:y", character_spatial.rotation.y, angle, time_to/10)
	$Tween.start()

func move_to(new_translation : Vector3, time_to : float = 1.0):
	target_position = new_translation
	var vector_mask : Vector3 = Vector3.FORWARD + Vector3.RIGHT
	var masked_translation : Vector3 = translation * vector_mask
	var new_masked_translation : Vector3 = target_position * vector_mask
	if new_masked_translation == masked_translation:
		return
	if $Tween.is_active():
		$Tween.stop_all()
	var angle = get_angle_on_y_axis(new_masked_translation)
	$Tween.interpolate_property(self, "translation", translation, new_translation, time_to)
	$Tween.interpolate_property(character_spatial, "rotation:y", character_spatial.rotation.y, angle, time_to/10)
	$Tween.start()

func go_home(time_to : float = 1.0):
	going_to = MoveTarget.HOME
	move_to(home_position, time_to)

func get_target_between(start_translation, target_translation, target_distance : float = 5.0) -> Vector3:
	var delta_vector : Vector3 =  target_translation - start_translation
	var shortened_vector = delta_vector - (delta_vector.normalized() * target_distance)
	return shortened_vector + start_translation

func go_to_character(character, time_to : float = 1.0):
	character_target = character
	going_to = MoveTarget.CHARACTER
	var target_nearby : Vector3 = get_target_between(home_position, character_target.home_position)
	move_to(target_nearby, time_to)

func move_to_current_target(time_to : float = 1.0):
	match(going_to):
		MoveTarget.HOME:
			go_home(time_to)
		MoveTarget.CHARACTER:
			go_to_character(character_target, time_to)
			
func add_item(item_type : int):
	var item_node
	match(item_type):
		ItemTypes.APPLE:
			item_node = apple_item
		ItemTypes.COINS:
			item_node = coins_item
	item_node.visible = true
	$AnimationPlayer.play("ReceiveItem")
	yield($AnimationPlayer, "animation_finished")
	item_node.visible = false

func no_item():
	no_item.visible = true
	$AnimationPlayer.play("GrowUpDown")
	yield($AnimationPlayer, "animation_finished")
	no_item.visible = false

func add_transaction(avg : float = 0.0):
	recent_transactions.append(avg)

func get_avg_of_array(values : Array):
	var sum : float = 0.0
	if values.size() == 0:
		return sum
	for i in values:
		sum += i
	return sum / values.size()

func get_weighted_avg_of_array(values : Array, cutoff : int = 5, weight_adjust : float = 0.8):
	var sum : float = 0.0
	var weight_sum : float = 0.0
	var iter : int = 0
	var reverse_values = values.duplicate()
	reverse_values.invert()
	var sliced_values : Array = reverse_values.slice(0, cutoff)
	for value in sliced_values:
		var current_weight = pow(weight_adjust, iter)
		sum += value * current_weight
		weight_sum += current_weight
		iter += 1
	return sum / weight_sum

func get_avg_of_all_transactions():
	return get_weighted_avg_of_array(all_transactions)

func get_avg_of_recent_transactions():
	return get_avg_of_array(recent_transactions)

func get_lower_expectations():
	return (price_point + current_price_point) / 2

func adjust_current_price_point():
	var avg : float = get_avg_of_recent_transactions()
	if avg == 0.0:
		avg = get_lower_expectations()
	all_transactions.append(avg)
	var weighted_avg : float = get_avg_of_all_transactions()
	set_current_price_point(weighted_avg)
	recent_transactions.clear()

func reset_history():
	all_transactions.clear()
	recent_transactions.clear()
	current_price_point = price_point
	for i in range(prefilled_price_points):
		all_transactions.append(price_point)

func _ready():
	$DoubleStatsBar3D.character = self
	$DoubleStatsBar3D.set_stat_scale(2.0)
