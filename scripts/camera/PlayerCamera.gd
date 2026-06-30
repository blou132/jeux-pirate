class_name PlayerCamera
extends Camera3D

@export var follow_target_path: NodePath
@export var follow_smoothing: float = 8.0
@export var rotation_smoothing: float = 10.0
@export var zoom_min_factor: float = 0.65
@export var zoom_max_factor: float = 1.75
@export var zoom_step: float = 0.12
@export var zoom_smoothing: float = 10.0
@export var look_offset_sensitivity: float = 0.035
@export var look_offset_max_distance: float = 22.0
@export var look_offset_smoothing: float = 8.0
@export var clamp_to_world_bounds: bool = true
@export var fallback_world_limit: Vector2 = Vector2(112.0, 112.0)
@export var world_bounds_padding: float = 4.0

var _target: Node3D
var _world_bounds: Node
var _base_local_offset: Vector3
var _base_pitch_degrees: float
var _current_zoom_factor: float = 1.0
var _target_zoom_factor: float = 1.0
var _current_look_offset: Vector3 = Vector3.ZERO
var _target_look_offset: Vector3 = Vector3.ZERO
var _is_looking_around: bool = false
var is_free_look_unlocked: bool = false


func _ready() -> void:
	_base_local_offset = position
	_base_pitch_degrees = rotation_degrees.x
	_target = _find_follow_target()
	_world_bounds = _find_world_bounds()
	top_level = true

	if _target != null:
		global_position = _get_desired_position()
		global_rotation = _get_desired_rotation()


func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		_target = _find_follow_target()
	if _target == null:
		return
	if not is_instance_valid(_world_bounds):
		_world_bounds = _find_world_bounds()

	var position_weight: float = _get_smoothing_weight(follow_smoothing, delta)
	var rotation_weight: float = _get_smoothing_weight(rotation_smoothing, delta)
	var zoom_weight: float = _get_smoothing_weight(zoom_smoothing, delta)
	var look_offset_weight: float = _get_smoothing_weight(look_offset_smoothing, delta)
	_current_zoom_factor = lerpf(_current_zoom_factor, _target_zoom_factor, zoom_weight)
	_current_look_offset = _current_look_offset.lerp(_target_look_offset, look_offset_weight)
	global_position = global_position.lerp(_get_desired_position(), position_weight)
	global_rotation = global_rotation.lerp(_get_desired_rotation(), rotation_weight)


func _unhandled_input(event: InputEvent) -> void:
	if _are_camera_controls_blocked():
		_is_looking_around = false
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_V:
			is_free_look_unlocked = not is_free_look_unlocked
			get_viewport().set_input_as_handled()
		elif key_event.pressed and not key_event.echo and key_event.keycode == KEY_C:
			recenter()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_is_looking_around = mouse_event.pressed
			return
		if not mouse_event.pressed:
			return

		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_zoom(-zoom_step)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_zoom(zoom_step)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and _is_looking_around:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		_add_look_offset(motion_event.relative)
		get_viewport().set_input_as_handled()


func _find_follow_target() -> Node3D:
	if not follow_target_path.is_empty():
		var path_target := get_node_or_null(follow_target_path) as Node3D
		if path_target != null:
			return path_target

	var parent_target := get_parent() as Node3D
	if parent_target != null:
		return parent_target

	return get_tree().get_first_node_in_group("player") as Node3D


func _find_world_bounds() -> Node:
	return get_tree().get_first_node_in_group("world_bounds")


func _get_desired_position() -> Vector3:
	var desired_position: Vector3 = _target.global_transform * ((_base_local_offset * _current_zoom_factor) + _current_look_offset)
	return _clamp_to_world_bounds(desired_position)


func _adjust_zoom(delta_factor: float) -> void:
	var min_zoom: float = minf(zoom_min_factor, zoom_max_factor)
	var max_zoom: float = maxf(zoom_min_factor, zoom_max_factor)
	_target_zoom_factor = clampf(_target_zoom_factor + delta_factor, min_zoom, max_zoom)


func recenter() -> void:
	_target_look_offset = Vector3.ZERO


func _add_look_offset(mouse_delta: Vector2) -> void:
	var next_offset: Vector3 = _target_look_offset
	next_offset.x += mouse_delta.x * look_offset_sensitivity
	next_offset.z += mouse_delta.y * look_offset_sensitivity
	_target_look_offset = _clamp_look_offset(next_offset)


func _clamp_look_offset(offset: Vector3) -> Vector3:
	var planar_offset: Vector2 = Vector2(offset.x, offset.z)
	var max_distance: float = maxf(0.0, look_offset_max_distance)
	if planar_offset.length() > max_distance:
		planar_offset = planar_offset.normalized() * max_distance

	return Vector3(planar_offset.x, 0.0, planar_offset.y)


func _clamp_to_world_bounds(world_position: Vector3) -> Vector3:
	if not clamp_to_world_bounds:
		return world_position

	var limit: Vector2 = _get_camera_limit()
	var x_limit: float = maxf(0.0, limit.x - world_bounds_padding)
	var z_limit: float = maxf(0.0, limit.y - world_bounds_padding)
	return Vector3(
		clampf(world_position.x, -x_limit, x_limit),
		world_position.y,
		clampf(world_position.z, -z_limit, z_limit)
	)


func _get_camera_limit() -> Vector2:
	if _world_bounds != null and _world_bounds.has_method("get_camera_limit"):
		var raw_limit: Variant = _world_bounds.call("get_camera_limit")
		if raw_limit is Vector2:
			return raw_limit

	return fallback_world_limit


func _are_camera_controls_blocked() -> bool:
	if get_tree().paused:
		return true

	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return false

	var menu_names: Array[String] = ["PortMenu", "IslandExplorationMenu"]
	for menu_name in menu_names:
		var menu: Node = current_scene.get_node_or_null(menu_name)
		if menu != null and menu.has_method("is_open") and bool(menu.call("is_open")):
			return true

	return false


func _get_desired_rotation() -> Vector3:
	return Vector3(
		deg_to_rad(_base_pitch_degrees),
		_target.global_rotation.y,
		0.0
	)


func _get_smoothing_weight(smoothing: float, delta: float) -> float:
	return 1.0 - exp(-maxf(0.0, smoothing) * delta)
