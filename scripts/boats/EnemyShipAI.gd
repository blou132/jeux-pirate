extends Node

@export var enemy_cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/EnemyCannonBall.tscn")
@export var detection_range: float = 55.0
@export var stop_distance: float = 7.0
@export var projectile_speed: float = 13.0
@export var broadside_tolerance_degrees: float = 60.0

@onready var ship: EnemyShip = get_parent() as EnemyShip

var _player: Node3D
var _attack_cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	if ship == null:
		return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D

	if _player == null:
		ship.brake(delta)
		return

	if _player.has_method("is_destroyed") and _player.is_destroyed():
		ship.brake(delta)
		return

	var offset := _player.global_position - ship.global_position
	offset.y = 0.0
	var distance_squared := offset.length_squared()
	var attack_range := _get_attack_range()

	if distance_squared > detection_range * detection_range:
		ship.brake(delta)
		return

	if distance_squared <= attack_range * attack_range:
		var fire_direction: Vector3 = _get_broadside_fire_direction(offset)
		if fire_direction == Vector3.ZERO:
			_maneuver_for_broadside(offset, delta)
			return

		ship.brake(delta)
		_try_attack_player(fire_direction)
		return

	ship.steer_toward(_player.global_position, delta)


func _try_attack_player(fire_direction: Vector3) -> void:
	if _attack_cooldown_remaining > 0.0 or _player == null:
		return

	var damage := 0
	if ship.has_method("get_contact_damage"):
		damage = ship.get_contact_damage()

	if damage <= 0:
		return

	_fire_projectile(damage, fire_direction)
	_attack_cooldown_remaining = _get_attack_cooldown()


func _get_attack_range() -> float:
	if ship.has_method("get_attack_range"):
		return ship.get_attack_range()

	return stop_distance


func _get_attack_cooldown() -> float:
	if ship.has_method("get_attack_cooldown"):
		return ship.get_attack_cooldown()

	return 2.0


func _get_broadside_fire_direction(offset_to_player: Vector3) -> Vector3:
	if offset_to_player.length_squared() < 0.01:
		return Vector3.ZERO

	var to_player := offset_to_player.normalized()
	var port_direction := -ship.global_transform.basis.x
	var starboard_direction := ship.global_transform.basis.x
	port_direction.y = 0.0
	starboard_direction.y = 0.0
	port_direction = port_direction.normalized()
	starboard_direction = starboard_direction.normalized()

	var port_alignment := to_player.dot(port_direction)
	var starboard_alignment := to_player.dot(starboard_direction)
	var required_alignment := cos(deg_to_rad(broadside_tolerance_degrees))

	if port_alignment >= starboard_alignment and port_alignment >= required_alignment:
		return port_direction
	if starboard_alignment >= required_alignment:
		return starboard_direction

	return Vector3.ZERO


func _maneuver_for_broadside(offset_to_player: Vector3, delta: float) -> void:
	if offset_to_player.length_squared() < 0.01:
		ship.brake(delta)
		return

	var to_player := offset_to_player.normalized()
	var broadside_forward := Vector3.UP.cross(to_player)
	if broadside_forward.length_squared() < 0.01:
		ship.brake(delta)
		return

	broadside_forward = broadside_forward.normalized()
	var opposite_forward := -broadside_forward
	var current_forward := -ship.global_transform.basis.z

	if current_forward.dot(opposite_forward) > current_forward.dot(broadside_forward):
		broadside_forward = opposite_forward

	if ship.has_method("steer_along_direction"):
		ship.steer_along_direction(broadside_forward, delta)
	else:
		ship.steer_toward(_player.global_position, delta)


func _fire_projectile(damage: int, fire_direction: Vector3) -> void:
	if enemy_cannon_ball_scene == null or not is_instance_valid(_player):
		return

	var projectile := enemy_cannon_ball_scene.instantiate()
	if not projectile is Node3D:
		projectile.queue_free()
		return

	var projectile_node := projectile as Node3D
	var start_position := ship.global_position + (fire_direction.normalized() * 1.5) + Vector3(0.0, 0.7, 0.0)
	var target_position := _player.global_position + Vector3(0.0, 0.45, 0.0)
	var direction := target_position - start_position
	direction.y = clampf(direction.y, -0.2, 0.35)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile)

	projectile_node.global_position = start_position

	if projectile.has_method("launch"):
		projectile.launch(direction, ship, projectile_speed, damage)
