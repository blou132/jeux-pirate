extends Node

const ORDER_FOLLOW := "follow"
const ORDER_ATTACK := "attack"
const ORDER_PROTECT := "protect"
const ORDER_FLEE := "flee"

@export var ally_cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/AllyCannonBall.tscn")
@export var follow_rear_offset: float = 12.0
@export var follow_side_offset: float = 6.0
@export var ideal_follow_distance: float = 12.0
@export var too_close_distance: float = 6.0
@export var too_far_distance: float = 25.0
@export var slot_tolerance: float = 2.5
@export var normal_speed_scale: float = 0.72
@export var catch_up_speed_scale: float = 1.0
@export var close_speed_scale: float = 0.35
@export var attack_detection_range: float = 35.0
@export var attack_damage: int = 8
@export var attack_cooldown: float = 2.5
@export var projectile_speed: float = 16.0
@export var broadside_alignment_degrees: float = 35.0
@export var broadside_line_tolerance: float = 1.35
@export var broadside_muzzle_offset: float = 1.35
@export var broadside_muzzle_height: float = 0.62
@export var combat_maneuver_speed_scale: float = 0.52
@export var broadside_line_correction_weight: float = 0.65
@export var ally_separation_distance: float = 5.0
@export var ally_separation_weight: float = 1.15
@export var follow_defense_range: float = 13.0
@export var protect_detection_range: float = 28.0
@export var flee_enemy_avoidance_weight: float = 1.25
@export var flee_slot_tolerance: float = 3.0

@onready var ship: AllyShip = get_parent() as AllyShip

var _player: Node3D
var _fleet_manager: Node
var _attack_cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	if ship == null or ship.is_destroyed():
		return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)

	_refresh_player()
	if _player == null:
		ship.brake(delta)
		return
	if _player.has_method("is_destroyed") and _player.is_destroyed():
		ship.brake(delta)
		return

	var player_position := _player.global_position
	player_position.y = 0.0
	var ship_position := ship.global_position
	ship_position.y = 0.0

	var fleet_order := _get_current_order()
	if fleet_order == ORDER_FLEE:
		_handle_flee_order(ship_position, delta)
		return

	var distance_to_player := ship_position.distance_to(player_position)
	if distance_to_player < too_close_distance:
		_move_away_from_player(player_position, ship_position, delta)
		return

	if _try_combat_support(delta, fleet_order):
		return

	var follow_slot := _get_follow_slot()
	var distance_to_slot := ship_position.distance_to(follow_slot)
	if distance_to_slot <= slot_tolerance:
		var close_separation := _get_ally_separation_direction()
		if close_separation == Vector3.ZERO:
			ship.brake(delta)
		else:
			ship.steer_along_direction_with_speed(close_separation, delta, close_speed_scale)
		return

	var desired_direction := follow_slot - ship_position
	desired_direction.y = 0.0
	var separation_direction := _get_ally_separation_direction()
	if separation_direction != Vector3.ZERO and desired_direction.length_squared() > 0.01:
		desired_direction = (desired_direction.normalized() + (separation_direction * ally_separation_weight)).normalized()

	if desired_direction.length_squared() < 0.01:
		ship.brake(delta)
	else:
		ship.steer_along_direction_with_speed(
			desired_direction.normalized(),
			delta,
			_get_follow_speed_scale(distance_to_slot)
		)


func _refresh_player() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node3D


func _get_follow_slot() -> Vector3:
	var fleet_manager := _get_fleet_manager()
	if fleet_manager != null and fleet_manager.has_method("get_follow_slot_for_ally"):
		var fleet_slot: Vector3 = fleet_manager.get_follow_slot_for_ally(ship)
		return fleet_slot

	var rear_direction: Vector3 = _player.global_transform.basis.z
	rear_direction.y = 0.0
	if rear_direction.length_squared() < 0.01:
		rear_direction = Vector3.BACK
	rear_direction = rear_direction.normalized()

	var side_direction: Vector3 = _player.global_transform.basis.x
	side_direction.y = 0.0
	if side_direction.length_squared() < 0.01:
		side_direction = Vector3.RIGHT
	side_direction = side_direction.normalized()

	var follow_slot: Vector3 = _player.global_position
	follow_slot += rear_direction * follow_rear_offset
	follow_slot += side_direction * follow_side_offset
	follow_slot.y = 0.0
	return follow_slot


func _get_fleet_manager() -> Node:
	if is_instance_valid(_fleet_manager):
		return _fleet_manager

	var world := get_tree().current_scene
	if world != null and world.has_method("get_fleet_manager"):
		_fleet_manager = world.get_fleet_manager()
	if _fleet_manager == null:
		_fleet_manager = get_tree().get_first_node_in_group("fleet_manager")

	return _fleet_manager


func _get_current_order() -> String:
	var fleet_manager := _get_fleet_manager()
	if fleet_manager != null and fleet_manager.has_method("get_current_order"):
		return String(fleet_manager.get_current_order())

	return ORDER_FOLLOW


func _get_follow_speed_scale(distance_to_slot: float) -> float:
	if distance_to_slot > too_far_distance:
		return catch_up_speed_scale
	if distance_to_slot < ideal_follow_distance:
		return close_speed_scale

	return normal_speed_scale


func _move_away_from_player(player_position: Vector3, ship_position: Vector3, delta: float) -> void:
	var away_direction := ship_position - player_position
	away_direction.y = 0.0
	if away_direction.length_squared() < 0.01:
		ship.brake(delta)
		return

	ship.steer_along_direction_with_speed(away_direction.normalized(), delta, close_speed_scale)


func _get_ally_separation_direction() -> Vector3:
	var separation := Vector3.ZERO
	var ship_position := ship.global_position
	ship_position.y = 0.0

	for ally in get_tree().get_nodes_in_group("ally_ships"):
		if ally == ship or not ally is Node3D:
			continue
		if ally.has_method("is_destroyed") and ally.is_destroyed():
			continue

		var ally_node := ally as Node3D
		var offset := ship_position - ally_node.global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance <= 0.01 or distance >= ally_separation_distance:
			continue

		separation += offset.normalized() * ((ally_separation_distance - distance) / ally_separation_distance)

	if separation.length_squared() < 0.01:
		return Vector3.ZERO

	return separation.normalized()


func _handle_flee_order(ship_position: Vector3, delta: float) -> void:
	var fleet_manager := _get_fleet_manager()
	var safe_slot: Vector3 = ship_position
	if fleet_manager != null and fleet_manager.has_method("get_safe_slot_for_ally"):
		safe_slot = fleet_manager.get_safe_slot_for_ally(ship)
	else:
		safe_slot = _get_follow_slot()

	var desired_direction := safe_slot - ship_position
	desired_direction.y = 0.0
	var closest_enemy := _get_closest_enemy(attack_detection_range)
	if closest_enemy != null:
		var away_from_enemy := ship_position - closest_enemy.global_position
		away_from_enemy.y = 0.0
		if away_from_enemy.length_squared() > 0.01:
			if desired_direction.length_squared() > 0.01:
				desired_direction = desired_direction.normalized()
			desired_direction += away_from_enemy.normalized() * flee_enemy_avoidance_weight

	if ship_position.distance_to(safe_slot) <= flee_slot_tolerance and closest_enemy == null:
		ship.brake(delta)
		return

	if desired_direction.length_squared() < 0.01:
		ship.brake(delta)
	else:
		ship.steer_along_direction_with_speed(desired_direction.normalized(), delta, catch_up_speed_scale)


func _try_combat_support(delta: float, fleet_order: String) -> bool:
	var target := _get_target_for_order(fleet_order)
	if target == null:
		return false

	var target_aim_position := _get_target_aim_position(target)
	var offset := target_aim_position - ship.global_position
	offset.y = 0.0
	var support_range := _get_support_range_for_order(fleet_order)
	if offset.length_squared() > support_range * support_range:
		return false

	var fire_direction := _get_ready_fire_direction(target)
	if fire_direction == Vector3.ZERO:
		_maneuver_for_broadside(target, delta)
		return true

	ship.brake(delta)
	_try_fire(fire_direction)
	return true


func _get_target_for_order(fleet_order: String) -> Node3D:
	match fleet_order:
		ORDER_ATTACK:
			return _get_closest_enemy(attack_detection_range)
		ORDER_PROTECT:
			return _get_closest_enemy_near_protected_ship()
		ORDER_FOLLOW:
			return _get_closest_enemy(follow_defense_range)

	return null


func _get_support_range_for_order(fleet_order: String) -> float:
	match fleet_order:
		ORDER_ATTACK:
			return attack_detection_range
		ORDER_PROTECT:
			return protect_detection_range
		ORDER_FOLLOW:
			return follow_defense_range

	return 0.0


func _get_closest_enemy(max_range: float) -> Node3D:
	var closest_enemy: Node3D
	var closest_distance_squared := max_range * max_range

	for enemy in get_tree().get_nodes_in_group("enemy_ships"):
		if not enemy is Node3D:
			continue
		if enemy.has_method("is_destroyed") and enemy.is_destroyed():
			continue

		var enemy_node := enemy as Node3D
		var distance_squared := ship.global_position.distance_squared_to(enemy_node.global_position)
		if distance_squared <= closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_enemy = enemy_node

	return closest_enemy


func _get_closest_enemy_near_protected_ship() -> Node3D:
	var closest_enemy: Node3D
	var closest_distance_squared := protect_detection_range * protect_detection_range

	for enemy in get_tree().get_nodes_in_group("enemy_ships"):
		if not enemy is Node3D:
			continue
		if enemy.has_method("is_destroyed") and enemy.is_destroyed():
			continue

		var enemy_node := enemy as Node3D
		if not _is_enemy_near_protected_ship(enemy_node):
			continue

		var distance_squared := ship.global_position.distance_squared_to(enemy_node.global_position)
		if distance_squared <= closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_enemy = enemy_node

	return closest_enemy


func _is_enemy_near_protected_ship(enemy: Node3D) -> bool:
	if _player != null and is_instance_valid(_player):
		if enemy.global_position.distance_squared_to(_player.global_position) <= protect_detection_range * protect_detection_range:
			return true

	for ally in get_tree().get_nodes_in_group("ally_ships"):
		if not ally is Node3D:
			continue
		if ally.has_method("is_destroyed") and ally.is_destroyed():
			continue

		var ally_node := ally as Node3D
		if enemy.global_position.distance_squared_to(ally_node.global_position) <= protect_detection_range * protect_detection_range:
			return true

	return false


func _get_ready_fire_direction(target: Node3D) -> Vector3:
	var target_aim_position := _get_target_aim_position(target)
	var offset_to_enemy := target_aim_position - ship.global_position
	offset_to_enemy.y = 0.0
	if offset_to_enemy.length_squared() < 0.01:
		return Vector3.ZERO

	var to_enemy := offset_to_enemy.normalized()
	var fire_direction := _get_preferred_fire_direction(offset_to_enemy)
	if fire_direction == Vector3.ZERO:
		return Vector3.ZERO

	var required_alignment := cos(deg_to_rad(broadside_alignment_degrees))
	if to_enemy.dot(fire_direction) < required_alignment:
		return Vector3.ZERO
	if not _is_broadside_aim_line_valid(fire_direction, target_aim_position):
		return Vector3.ZERO

	return fire_direction


func _maneuver_for_broadside(target: Node3D, delta: float) -> void:
	var target_aim_position := _get_target_aim_position(target)
	var offset_to_enemy := target_aim_position - ship.global_position
	offset_to_enemy.y = 0.0
	if offset_to_enemy.length_squared() < 0.01:
		ship.brake(delta)
		return

	var to_enemy := offset_to_enemy.normalized()
	var desired_forward := Vector3.UP.cross(to_enemy)
	if desired_forward.length_squared() < 0.01:
		ship.brake(delta)
		return

	desired_forward = desired_forward.normalized()
	var opposite_forward := -desired_forward
	var current_forward := -ship.global_transform.basis.z
	current_forward.y = 0.0
	if current_forward.dot(opposite_forward) > current_forward.dot(desired_forward):
		desired_forward = opposite_forward

	var preferred_fire_direction := _get_preferred_fire_direction(offset_to_enemy)
	var line_error := _get_broadside_line_error(preferred_fire_direction, target_aim_position)
	if line_error.length_squared() > broadside_line_tolerance * broadside_line_tolerance:
		desired_forward = (desired_forward + (line_error.normalized() * broadside_line_correction_weight)).normalized()

	ship.steer_along_direction_with_speed(desired_forward, delta, combat_maneuver_speed_scale)


func _try_fire(fire_direction: Vector3) -> void:
	if _attack_cooldown_remaining > 0.0 or ally_cannon_ball_scene == null:
		return

	var projectile := ally_cannon_ball_scene.instantiate()
	if not projectile is Node3D:
		projectile.queue_free()
		return

	var projectile_node := projectile as Node3D
	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile_node)
	projectile_node.global_position = _get_broadside_muzzle_position(fire_direction)

	if projectile.has_method("launch"):
		projectile.launch(fire_direction.normalized(), ship, projectile_speed, attack_damage)

	_attack_cooldown_remaining = attack_cooldown


func _get_target_aim_position(target: Node3D) -> Vector3:
	if target != null and target.has_method("get_aim_position"):
		var aim_position: Vector3 = target.get_aim_position()
		return aim_position

	return target.global_position


func _get_preferred_fire_direction(offset_to_enemy: Vector3) -> Vector3:
	if offset_to_enemy.length_squared() < 0.01:
		return Vector3.ZERO

	var to_enemy := offset_to_enemy.normalized()
	var starboard_axis: Vector3 = ship.get_starboard_axis()
	var port_axis: Vector3 = ship.get_port_axis()
	if to_enemy.dot(port_axis) > to_enemy.dot(starboard_axis):
		return port_axis

	return starboard_axis


func _is_broadside_aim_line_valid(fire_direction: Vector3, target_aim_position: Vector3) -> bool:
	if fire_direction.length_squared() < 0.01:
		return false

	var line_origin := _get_broadside_muzzle_position(fire_direction)
	var line_direction := fire_direction.normalized()
	line_direction.y = 0.0
	if line_direction.length_squared() < 0.01:
		return false

	var to_target := target_aim_position - line_origin
	var parallel_distance := to_target.dot(line_direction)
	if parallel_distance <= 0.0:
		return false

	var closest_point := line_origin + (line_direction * parallel_distance)
	var perpendicular_distance := target_aim_position.distance_to(closest_point)
	return perpendicular_distance <= broadside_line_tolerance


func _get_broadside_line_error(fire_direction: Vector3, target_aim_position: Vector3) -> Vector3:
	if fire_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var line_origin := _get_broadside_muzzle_position(fire_direction)
	var line_direction := fire_direction.normalized()
	line_direction.y = 0.0
	if line_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var to_target := target_aim_position - line_origin
	var parallel_distance := maxf(0.0, to_target.dot(line_direction))
	var closest_point := line_origin + (line_direction * parallel_distance)
	var error := target_aim_position - closest_point
	error.y = 0.0
	return error


func _get_broadside_muzzle_position(fire_direction: Vector3) -> Vector3:
	return ship.get_broadside_cannon_position(
		fire_direction,
		broadside_muzzle_offset,
		broadside_muzzle_height
	)
