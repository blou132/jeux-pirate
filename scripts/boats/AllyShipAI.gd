extends Node

@export var follow_rear_offset: float = 12.0
@export var follow_side_offset: float = 6.0
@export var ideal_follow_distance: float = 12.0
@export var too_close_distance: float = 6.0
@export var too_far_distance: float = 25.0
@export var slot_tolerance: float = 2.5
@export var normal_speed_scale: float = 0.72
@export var catch_up_speed_scale: float = 1.0
@export var close_speed_scale: float = 0.35

@onready var ship: AllyShip = get_parent() as AllyShip

var _player: Node3D


func _physics_process(delta: float) -> void:
	if ship == null or ship.is_destroyed():
		return

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
