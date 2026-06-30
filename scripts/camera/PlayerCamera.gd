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
var _base_yaw_degrees: float
var _current_zoom_factor: float = 1.0
var _target_zoom_factor: float = 1.0
var _current_look_offset: Vector3 = Vector3.ZERO
var _target_look_offset: Vector3 = Vector3.ZERO
var is_free_look_unlocked: bool = false


func _ready() -> void:
	_base_local_offset = position
	_base_pitch_degrees = rotation_degrees.x
	_base_yaw_degrees = rotation_degrees.y
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
	_refresh_free_look_target()
	_current_zoom_factor = lerpf(_current_zoom_factor, _target_zoom_factor, zoom_weight)
	_current_look_offset = _current_look_offset.lerp(_target_look_offset, look_offset_weight)
	global_position = global_position.lerp(_get_desired_position(), position_weight)
	global_rotation = global_rotation.lerp(_get_desired_rotation(), rotation_weight)


func _unhandled_input(event: InputEvent) -> void:
	if _are_camera_controls_blocked():
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_V:
			is_free_look_unlocked = not is_free_look_unlocked
			_show_lock_feedback()
			get_viewport().set_input_as_handled()
		elif key_event.pressed and not key_event.echo and key_event.keycode == KEY_C:
			recenter()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed:
			return

		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_zoom(-zoom_step)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_zoom(zoom_step)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and is_free_look_unlocked:
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
	var desired_position: Vector3 = _target.global_position + (_base_local_offset * _current_zoom_factor) + _current_look_offset
	return _clamp_to_world_bounds(desired_position)


func _adjust_zoom(delta_factor: float) -> void:
	var min_zoom: float = minf(zoom_min_factor, zoom_max_factor)
	var max_zoom: float = maxf(zoom_min_factor, zoom_max_factor)
	_target_zoom_factor = clampf(_target_zoom_factor + delta_factor, min_zoom, max_zoom)


func recenter() -> void:
	_target_look_offset = Vector3.ZERO


func _refresh_free_look_target() -> void:
	if not is_free_look_unlocked:
		return

	var viewport: Viewport = get_viewport()
	var viewport_center: Vector2 = viewport.get_visible_rect().size * 0.5
	var mouse_from_center: Vector2 = viewport.get_mouse_position() - viewport_center
	var planar_offset: Vector2 = mouse_from_center * look_offset_sensitivity
	if planar_offset.length() > look_offset_max_distance:
		planar_offset = planar_offset.normalized() * look_offset_max_distance

	_target_look_offset = Vector3(planar_offset.x, 0.0, planar_offset.y)


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


func _show_lock_feedback() -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud == null or not hud.has_method("show_temporary_context_message"):
		return

	var message: String = "Camera libre activee"
	if not is_free_look_unlocked:
		message = "Camera verrouillee"

	hud.call("show_temporary_context_message", message, 1.1)


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
		deg_to_rad(_base_yaw_degrees),
		0.0
	)


func _get_smoothing_weight(smoothing: float, delta: float) -> float:
	return 1.0 - exp(-maxf(0.0, smoothing) * delta)
