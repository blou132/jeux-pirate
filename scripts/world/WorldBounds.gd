extends Node

signal boundary_warning
signal player_returned

@export var soft_limit: Vector2 = Vector2(92.0, 92.0)
@export var hard_limit: Vector2 = Vector2(112.0, 112.0)
@export var push_speed: float = 16.0
@export var safe_port_offset: Vector3 = Vector3(8.0, 0.0, -8.0)
@export var warning_message: String = "Limite de la carte"
@export var return_message: String = "Retour dans la zone navigable"
@export var feedback_cooldown: float = 1.4

var _player: Node3D
var _feedback_cooldown_remaining: float = 0.0


func _ready() -> void:
	add_to_group("world_bounds")


func _physics_process(delta: float) -> void:
	_feedback_cooldown_remaining = maxf(0.0, _feedback_cooldown_remaining - delta)
	_refresh_player()
	if _player == null:
		return

	var player_position: Vector3 = _player.global_position
	if _is_outside_limit(player_position, hard_limit):
		_return_player_to_safe_area()
		_show_bounds_feedback(return_message, 1.8, true)
		player_returned.emit()
		return

	if _is_outside_limit(player_position, soft_limit):
		_push_player_inside(delta)
		_show_bounds_feedback(warning_message, 1.0)
		boundary_warning.emit()


func _refresh_player() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node3D


func _is_outside_limit(world_position: Vector3, limit: Vector2) -> bool:
	return absf(world_position.x) > limit.x or absf(world_position.z) > limit.y


func get_camera_limit() -> Vector2:
	return hard_limit


func _push_player_inside(delta: float) -> void:
	var target_position: Vector3 = _clamp_to_limit(_player.global_position, soft_limit)
	target_position.y = 0.0
	_player.global_position = _player.global_position.move_toward(target_position, push_speed * delta)


func _return_player_to_safe_area() -> void:
	var safe_position: Vector3 = _get_safe_position()
	if _player.has_method("return_to_safe_position"):
		_player.return_to_safe_position(safe_position)
		return

	safe_position.y = 0.0
	_player.global_position = safe_position


func _show_bounds_feedback(message: String, duration: float, force: bool = false) -> void:
	if not force and _feedback_cooldown_remaining > 0.0:
		return

	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, duration)

	_feedback_cooldown_remaining = feedback_cooldown


func _get_safe_position() -> Vector3:
	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		return port.global_position + safe_port_offset

	return Vector3.ZERO


func _clamp_to_limit(world_position: Vector3, limit: Vector2) -> Vector3:
	return Vector3(
		clampf(world_position.x, -limit.x, limit.x),
		world_position.y,
		clampf(world_position.z, -limit.y, limit.y)
	)
