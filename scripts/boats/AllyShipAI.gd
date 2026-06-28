extends Node

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
@export var broadside_muzzle_offset: float = 1.35
@export var broadside_muzzle_height: float = 0.62
@export var combat_maneuver_speed_scale: float = 0.52

@onready var ship: AllyShip = get_parent() as AllyShip

var _player: Node3D
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

	var distance_to_player := ship_position.distance_to(player_position)
	if distance_to_player < too_close_distance:
		_move_away_from_player(player_position, ship_position, delta)
		return

	if _try_combat_support(delta):
		return

	var follow_slot := _get_follow_slot()
	var distance_to_slot := ship_position.distance_to(follow_slot)
	if distance_to_slot <= slot_tolerance:
		ship.brake(delta)
		return

	ship.steer_toward(follow_slot, delta, _get_follow_speed_scale(distance_to_slot))


func _refresh_player() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node3D


func _get_follow_slot() -> Vector3:
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


func _try_combat_support(delta: float) -> bool:
	var target := _get_closest_enemy()
	if target == null:
		return false

	var offset := target.global_position - ship.global_position
	offset.y = 0.0
	if offset.length_squared() > attack_detection_range * attack_detection_range:
		return false

	var fire_direction := _get_ready_fire_direction(offset)
	if fire_direction == Vector3.ZERO:
		_maneuver_for_broadside(offset, delta)
		return true

	ship.brake(delta)
	_try_fire(fire_direction)
	return true


func _get_closest_enemy() -> Node3D:
	var closest_enemy: Node3D
	var closest_distance_squared := attack_detection_range * attack_detection_range

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


func _get_ready_fire_direction(offset_to_enemy: Vector3) -> Vector3:
	if offset_to_enemy.length_squared() < 0.01:
		return Vector3.ZERO

	var to_enemy := offset_to_enemy.normalized()
	var starboard_axis: Vector3 = ship.get_starboard_axis()
	var port_axis: Vector3 = ship.get_port_axis()
	var fire_direction := starboard_axis
	if to_enemy.dot(port_axis) > to_enemy.dot(starboard_axis):
		fire_direction = port_axis

	var required_alignment := cos(deg_to_rad(broadside_alignment_degrees))
	if to_enemy.dot(fire_direction) < required_alignment:
		return Vector3.ZERO

	return fire_direction


func _maneuver_for_broadside(offset_to_enemy: Vector3, delta: float) -> void:
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
	projectile_node.global_position = ship.get_broadside_cannon_position(
		fire_direction,
		broadside_muzzle_offset,
		broadside_muzzle_height
	)

	if projectile.has_method("launch"):
		projectile.launch(fire_direction.normalized(), ship, projectile_speed, attack_damage)

	_attack_cooldown_remaining = attack_cooldown
