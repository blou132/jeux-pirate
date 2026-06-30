class_name PlayerCamera
extends Camera3D

@export var follow_target_path: NodePath
@export var follow_smoothing: float = 8.0
@export var rotation_smoothing: float = 10.0

var _target: Node3D
var _base_local_offset: Vector3
var _base_pitch_degrees: float


func _ready() -> void:
	_base_local_offset = position
	_base_pitch_degrees = rotation_degrees.x
	_target = _find_follow_target()
	top_level = true

	if _target != null:
		global_position = _get_desired_position()
		global_rotation = _get_desired_rotation()


func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		_target = _find_follow_target()
	if _target == null:
		return

	var position_weight: float = _get_smoothing_weight(follow_smoothing, delta)
	var rotation_weight: float = _get_smoothing_weight(rotation_smoothing, delta)
	global_position = global_position.lerp(_get_desired_position(), position_weight)
	global_rotation = global_rotation.lerp(_get_desired_rotation(), rotation_weight)


func _find_follow_target() -> Node3D:
	if not follow_target_path.is_empty():
		var path_target := get_node_or_null(follow_target_path) as Node3D
		if path_target != null:
			return path_target

	var parent_target := get_parent() as Node3D
	if parent_target != null:
		return parent_target

	return get_tree().get_first_node_in_group("player") as Node3D


func _get_desired_position() -> Vector3:
	return _target.global_transform * _base_local_offset


func _get_desired_rotation() -> Vector3:
	return Vector3(
		deg_to_rad(_base_pitch_degrees),
		_target.global_rotation.y,
		0.0
	)


func _get_smoothing_weight(smoothing: float, delta: float) -> float:
	return 1.0 - exp(-maxf(0.0, smoothing) * delta)
