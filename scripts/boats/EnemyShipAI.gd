extends Node

@export var enemy_cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/EnemyCannonBall.tscn")
@export var detection_range: float = 55.0
@export var stop_distance: float = 7.0
@export var projectile_speed: float = 13.0
@export var broadside_fire_alignment_degrees: float = 25.0
@export var broadside_muzzle_offset: float = 2.2
@export var broadside_muzzle_height: float = 0.75
@export var broadside_preferred_distance_ratio: float = 0.78
@export var broadside_distance_margin: float = 1.5
@export var broadside_radial_weight: float = 0.55
@export var broadside_maneuver_speed_scale: float = 0.45
@export var broadside_retreat_speed_scale: float = 0.6
# Temporary v0.3.5 console helper to verify enemy broadside selection during tests.
@export var debug_broadside_fire: bool = true
@export var debug_broadside_fire_interval: float = 1.5

@onready var ship: EnemyShip = get_parent() as EnemyShip

var _player: Node3D
var _attack_cooldown_remaining: float = 0.0
var _debug_message_cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	if ship == null:
		return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_debug_message_cooldown_remaining = maxf(0.0, _debug_message_cooldown_remaining - delta)

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D

	if _player == null:
		ship.brake(delta)
		return

	if _player.has_method("is_destroyed") and _player.is_destroyed():
		ship.brake(delta)
		return

	var offset: Vector3 = _player.global_position - ship.global_position
	offset.y = 0.0
	var distance_squared: float = offset.length_squared()
	var attack_range: float = _get_attack_range()
	var distance_to_player: float = sqrt(distance_squared)

	if distance_squared > detection_range * detection_range:
		ship.brake(delta)
		return

	if distance_squared <= attack_range * attack_range:
		var fire_direction: Vector3 = _get_broadside_fire_direction(offset)
		if fire_direction == Vector3.ZERO:
			_maneuver_for_broadside(offset, distance_to_player, attack_range, delta)
			return

		ship.brake(delta)
		_try_attack_player(fire_direction)
		return

	ship.steer_toward(_player.global_position, delta)


func _try_attack_player(fire_direction: Vector3) -> void:
	if _attack_cooldown_remaining > 0.0 or _player == null:
		return

	var confirmed_fire_direction: Vector3 = _get_confirmed_broadside_fire_direction(fire_direction)
	if confirmed_fire_direction == Vector3.ZERO:
		return

	var damage := 0
	if ship.has_method("get_contact_damage"):
		damage = ship.get_contact_damage()

	if damage <= 0:
		return

	_show_broadside_debug(confirmed_fire_direction)
	_fire_projectile(damage, confirmed_fire_direction)
	_attack_cooldown_remaining = _get_attack_cooldown()


func _get_attack_range() -> float:
	if ship.has_method("get_attack_range"):
		return ship.get_attack_range()

	return stop_distance


func _get_attack_cooldown() -> float:
	if ship.has_method("get_attack_cooldown"):
		return ship.get_attack_cooldown()

	return 2.0


func _get_confirmed_broadside_fire_direction(candidate_direction: Vector3) -> Vector3:
	if not is_instance_valid(_player):
		return Vector3.ZERO
	if candidate_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var offset_to_player: Vector3 = _player.global_position - ship.global_position
	offset_to_player.y = 0.0
	var aligned_direction: Vector3 = _get_broadside_fire_direction(offset_to_player)
	if aligned_direction == Vector3.ZERO:
		return Vector3.ZERO

	if aligned_direction.normalized().dot(candidate_direction.normalized()) <= 0.0:
		return Vector3.ZERO

	return aligned_direction


func _get_broadside_fire_direction(offset_to_player: Vector3) -> Vector3:
	if offset_to_player.length_squared() < 0.01:
		return Vector3.ZERO

	var to_player: Vector3 = offset_to_player.normalized()
	var port_direction: Vector3 = -ship.global_transform.basis.x
	var starboard_direction: Vector3 = ship.global_transform.basis.x
	port_direction.y = 0.0
	starboard_direction.y = 0.0
	port_direction = port_direction.normalized()
	starboard_direction = starboard_direction.normalized()

	var port_alignment: float = to_player.dot(port_direction)
	var starboard_alignment: float = to_player.dot(starboard_direction)
	var required_alignment: float = cos(deg_to_rad(broadside_fire_alignment_degrees))

	if port_alignment >= starboard_alignment and port_alignment >= required_alignment:
		return port_direction
	if starboard_alignment >= required_alignment:
		return starboard_direction

	return Vector3.ZERO


func _maneuver_for_broadside(offset_to_player: Vector3, distance_to_player: float, attack_range: float, delta: float) -> void:
	if offset_to_player.length_squared() < 0.01:
		ship.brake(delta)
		return

	var to_player: Vector3 = offset_to_player.normalized()
	var desired_forward: Vector3 = _get_desired_broadside_forward(to_player)
	if desired_forward.length_squared() < 0.01:
		ship.brake(delta)
		return

	var preferred_distance: float = attack_range * broadside_preferred_distance_ratio
	var speed_scale: float = broadside_maneuver_speed_scale

	if distance_to_player < preferred_distance - broadside_distance_margin:
		speed_scale = broadside_retreat_speed_scale
		desired_forward = (desired_forward + (-to_player * broadside_radial_weight)).normalized()
	elif distance_to_player > preferred_distance + broadside_distance_margin:
		desired_forward = (desired_forward + (to_player * broadside_radial_weight)).normalized()

	if ship.has_method("steer_along_direction_with_speed"):
		ship.steer_along_direction_with_speed(desired_forward, delta, speed_scale)
	elif ship.has_method("steer_along_direction"):
		ship.steer_along_direction(desired_forward, delta)
	else:
		ship.steer_toward(_player.global_position, delta)


func _get_desired_broadside_forward(to_player: Vector3) -> Vector3:
	var broadside_forward: Vector3 = Vector3.UP.cross(to_player)
	if broadside_forward.length_squared() < 0.01:
		return Vector3.ZERO

	broadside_forward = broadside_forward.normalized()
	var opposite_forward: Vector3 = -broadside_forward
	var current_forward: Vector3 = -ship.global_transform.basis.z

	if current_forward.dot(opposite_forward) > current_forward.dot(broadside_forward):
		return opposite_forward

	return broadside_forward


func _fire_projectile(damage: int, fire_direction: Vector3) -> void:
	if enemy_cannon_ball_scene == null or not is_instance_valid(_player):
		return

	var projectile := enemy_cannon_ball_scene.instantiate()
	if not projectile is Node3D:
		projectile.queue_free()
		return

	var projectile_node := projectile as Node3D
	var start_position: Vector3 = _get_broadside_muzzle_position(fire_direction)
	var shot_direction: Vector3 = fire_direction.normalized()
	shot_direction.y = 0.0

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile)

	projectile_node.global_position = start_position

	if projectile.has_method("launch"):
		projectile.launch(shot_direction, ship, projectile_speed, damage)


func _get_broadside_muzzle_position(fire_direction: Vector3) -> Vector3:
	if ship.has_method("get_broadside_cannon_position"):
		return ship.get_broadside_cannon_position(
			fire_direction,
			broadside_muzzle_offset,
			broadside_muzzle_height
		)

	var side_direction: Vector3 = fire_direction.normalized()
	side_direction.y = 0.0
	return ship.global_position + (side_direction * broadside_muzzle_offset) + Vector3(0.0, broadside_muzzle_height, 0.0)


func _show_broadside_debug(fire_direction: Vector3) -> void:
	if not debug_broadside_fire:
		return
	if _debug_message_cooldown_remaining > 0.0:
		return

	var starboard_direction: Vector3 = ship.global_transform.basis.x.normalized()
	var side_name: String = "tribord"
	if fire_direction.normalized().dot(starboard_direction) < 0.0:
		side_name = "babord"

	print("Tir ennemi %s" % side_name)
	_debug_message_cooldown_remaining = debug_broadside_fire_interval
