class_name PlayerCamera
extends Camera3D

@export var follow_target_path: NodePath
@export var follow_smoothing: float = 8.0
@export var rotation_smoothing: float = 10.0
@export var zoom_min_factor: float = 0.65
@export var zoom_max_factor: float = 1.75
@export var zoom_step: float = 0.12
@export var zoom_smoothing: float = 10.0
@export var look_offset_sensitivity: float = 0.025
@export var look_offset_max_distance: float = 12.0
@export var look_offset_smoothing: float = 8.0
@export var camera_distance: float = 16.0
@export var camera_height: float = 10.0
@export var min_camera_height: float = 5.0
@export var max_camera_height: float = 18.0
@export var camera_height_step: float = 1.0
@export var height_smoothing: float = 8.0
@export var look_at_height: float = 2.0
@export var low_camera_look_at_height: float = 3.0
@export var high_camera_look_at_height: float = 1.5
@export var clamp_to_world_bounds: bool = true
@export var fallback_world_limit: Vector2 = Vector2(112.0, 112.0)
@export var world_bounds_padding: float = 4.0

var _target: Node3D
var _world_bounds: Node
var _current_zoom_factor: float = 1.0
var _target_zoom_factor: float = 1.0
var _current_look_offset: Vector3 = Vector3.ZERO
var _target_look_offset: Vector3 = Vector3.ZERO
var is_free_look_unlocked: bool = false
var _free_look_anchor_position: Vector2 = Vector2.ZERO
var _has_free_look_anchor: bool = false
var _current_camera_height: float = 10.0
var _target_camera_height: float = 10.0


func _ready() -> void:
	_target = _find_follow_target()
	_world_bounds = _find_world_bounds()
	top_level = true
	_target_camera_height = _get_clamped_camera_height(camera_height)
	_current_camera_height = _target_camera_height

	if _target != null:
		global_position = _get_desired_position()
		_apply_look_at_rotation(1.0)


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
	var height_weight: float = _get_smoothing_weight(height_smoothing, delta)
	_refresh_free_look_target()
	_current_zoom_factor = lerpf(_current_zoom_factor, _target_zoom_factor, zoom_weight)
	_current_look_offset = _current_look_offset.lerp(_target_look_offset, look_offset_weight)
	_current_camera_height = lerpf(_current_camera_height, _target_camera_height, height_weight)
	global_position = global_position.lerp(_get_desired_position(), position_weight)
	_apply_look_at_rotation(rotation_weight)


func _unhandled_input(event: InputEvent) -> void:
	if _are_camera_controls_blocked():
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_V:
			_set_free_look_unlocked(not is_free_look_unlocked)
			_show_lock_feedback()
			get_viewport().set_input_as_handled()
		elif key_event.pressed and not key_event.echo and key_event.keycode == KEY_C:
			recenter()
			get_viewport().set_input_as_handled()
		elif key_event.pressed and not key_event.echo and key_event.keycode == KEY_PAGEUP:
			_adjust_camera_height(camera_height_step)
			get_viewport().set_input_as_handled()
		elif key_event.pressed and not key_event.echo and key_event.keycode == KEY_PAGEDOWN:
			_adjust_camera_height(-camera_height_step)
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
	var boat_back: Vector3 = _get_boat_back_direction()
	var desired_position: Vector3 = _target.global_position
	desired_position += boat_back * (camera_distance * _current_zoom_factor)
	desired_position += Vector3.UP * _current_camera_height
	desired_position += _current_look_offset
	return _clamp_to_world_bounds(desired_position)


func _get_boat_back_direction() -> Vector3:
	var boat_back: Vector3 = _target.global_transform.basis.z
	boat_back.y = 0.0
	if boat_back.length_squared() < 0.001:
		return Vector3.BACK

	return boat_back.normalized()


func _adjust_zoom(delta_factor: float) -> void:
	var min_zoom: float = minf(zoom_min_factor, zoom_max_factor)
	var max_zoom: float = maxf(zoom_min_factor, zoom_max_factor)
	_target_zoom_factor = clampf(_target_zoom_factor + delta_factor, min_zoom, max_zoom)


func _adjust_camera_height(delta_height: float) -> void:
	_target_camera_height = _get_clamped_camera_height(_target_camera_height + delta_height)


func _get_clamped_camera_height(raw_height: float) -> float:
	return clampf(raw_height, _get_min_camera_height(), _get_max_camera_height())


func _get_min_camera_height() -> float:
	return minf(min_camera_height, max_camera_height)


func _get_max_camera_height() -> float:
	return maxf(min_camera_height, max_camera_height)


func recenter() -> void:
	_target_look_offset = Vector3.ZERO
	if is_free_look_unlocked:
		_free_look_anchor_position = get_viewport().get_mouse_position()
		_has_free_look_anchor = true


func _refresh_free_look_target() -> void:
	if not is_free_look_unlocked:
		_target_look_offset = Vector3.ZERO
		return

	var viewport: Viewport = get_viewport()
	var mouse_from_anchor: Vector2 = viewport.get_mouse_position() - _get_free_look_anchor_position()
	var planar_offset: Vector2 = mouse_from_anchor * look_offset_sensitivity
	if planar_offset.length() > look_offset_max_distance:
		planar_offset = planar_offset.normalized() * look_offset_max_distance

	_target_look_offset = Vector3(planar_offset.x, 0.0, planar_offset.y)


func _set_free_look_unlocked(is_unlocked: bool) -> void:
	is_free_look_unlocked = is_unlocked
	if is_free_look_unlocked:
		_free_look_anchor_position = get_viewport().get_mouse_position()
		_has_free_look_anchor = true
	else:
		_target_look_offset = Vector3.ZERO
		_has_free_look_anchor = false


func _get_free_look_anchor_position() -> Vector2:
	if not _has_free_look_anchor:
		_free_look_anchor_position = get_viewport().get_mouse_position()
		_has_free_look_anchor = true

	return _free_look_anchor_position


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


func _apply_look_at_rotation(weight: float) -> void:
	var look_position: Vector3 = _target.global_position + (Vector3.UP * _get_current_look_at_height())
	var desired_transform: Transform3D = global_transform.looking_at(look_position, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(desired_transform.basis, clampf(weight, 0.0, 1.0)).orthonormalized()


func _get_current_look_at_height() -> float:
	var height_span: float = _get_max_camera_height() - _get_min_camera_height()
	if height_span <= 0.001:
		return look_at_height

	var height_ratio: float = clampf((_current_camera_height - _get_min_camera_height()) / height_span, 0.0, 1.0)
	return lerpf(low_camera_look_at_height, high_camera_look_at_height, height_ratio)


func _get_smoothing_weight(smoothing: float, delta: float) -> float:
	return 1.0 - exp(-maxf(0.0, smoothing) * delta)
