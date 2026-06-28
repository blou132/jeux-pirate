class_name AllyShip
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal destroyed

@export var display_name: String = "Sloop allié"
@export var hud_name: String = "Sloop"
@export var max_health: int = 80
@export var move_speed: float = 6.2
@export var acceleration: float = 8.0
@export var turn_speed: float = 1.6
@export var turn_acceleration: float = 3.0
@export var turn_deceleration: float = 3.4
@export var cannon_point_base_half_width: float = 1.05
@export var cannon_point_height: float = 0.58
@export var cannon_point_forward_offset: float = -0.2

var health: int
var angular_velocity: float = 0.0

var _current_speed: float = 0.0
var _destroyed: bool = false


func _ready() -> void:
	health = max_health
	add_to_group("ally_ships")
	_refresh_cannon_points()
	_refresh_nameplate()
	health_changed.emit(health, max_health)


func steer_toward(target_position: Vector3, delta: float, speed_scale: float = 1.0) -> void:
	if _destroyed:
		return

	var to_target := target_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() < 0.25:
		brake(delta)
		return

	steer_along_direction_with_speed(to_target.normalized(), delta, speed_scale)


func steer_along_direction_with_speed(desired_forward: Vector3, delta: float, speed_scale: float) -> void:
	if _destroyed:
		return
	if desired_forward.length_squared() < 0.01:
		brake(delta)
		return

	desired_forward.y = 0.0
	desired_forward = desired_forward.normalized()
	var current_forward: Vector3 = -global_transform.basis.z
	current_forward.y = 0.0
	if current_forward.length_squared() < 0.01:
		brake(delta)
		return

	current_forward = current_forward.normalized()
	var signed_angle: float = current_forward.signed_angle_to(desired_forward, Vector3.UP)
	var target_angular_velocity: float = clampf(
		signed_angle * turn_acceleration,
		-turn_speed,
		turn_speed
	)
	angular_velocity = move_toward(
		angular_velocity,
		target_angular_velocity,
		turn_acceleration * delta
	)

	if absf(signed_angle) < 0.02:
		angular_velocity = move_toward(angular_velocity, 0.0, turn_deceleration * delta)

	var turn_amount: float = angular_velocity * delta
	if absf(turn_amount) > absf(signed_angle):
		turn_amount = signed_angle
		angular_velocity = 0.0

	rotate_y(turn_amount)
	_current_speed = move_toward(
		_current_speed,
		move_speed * clampf(speed_scale, 0.0, 1.0),
		acceleration * delta
	)
	velocity = -global_transform.basis.z * _current_speed
	move_and_slide()
	global_position.y = 0.0


func brake(delta: float) -> void:
	angular_velocity = move_toward(angular_velocity, 0.0, turn_deceleration * delta)
	_current_speed = move_toward(_current_speed, 0.0, acceleration * delta)
	velocity = -global_transform.basis.z * _current_speed
	move_and_slide()
	global_position.y = 0.0


func take_damage(amount: int) -> void:
	if _destroyed:
		return

	health = clampi(health - amount, 0, max_health)
	health_changed.emit(health, max_health)
	if health <= 0:
		_destroy()


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_display_name() -> String:
	return display_name


func get_hud_name() -> String:
	return hud_name


func is_destroyed() -> bool:
	return _destroyed


func get_starboard_axis() -> Vector3:
	var left_point := get_node_or_null("LeftCannonPoint") as Node3D
	var right_point := get_node_or_null("RightCannonPoint") as Node3D
	if left_point != null and right_point != null:
		var marker_axis: Vector3 = right_point.global_position - left_point.global_position
		marker_axis.y = 0.0
		if marker_axis.length_squared() > 0.01:
			return marker_axis.normalized()

	var fallback_axis: Vector3 = global_transform.basis.x
	fallback_axis.y = 0.0
	return fallback_axis.normalized()


func get_port_axis() -> Vector3:
	return -get_starboard_axis()


func get_broadside_cannon_position(fire_direction: Vector3, fallback_offset: float, fallback_height: float) -> Vector3:
	var cannon_point := _get_broadside_cannon_point(fire_direction)
	if cannon_point != null:
		return cannon_point.global_position

	var side_direction := fire_direction.normalized()
	side_direction.y = 0.0
	return global_position + (side_direction * fallback_offset) + Vector3(0.0, fallback_height, 0.0)


func _destroy() -> void:
	_destroyed = true
	angular_velocity = 0.0
	_current_speed = 0.0
	velocity = Vector3.ZERO
	destroyed.emit()
	queue_free()


func _refresh_nameplate() -> void:
	var nameplate := get_node_or_null("Nameplate") as Label3D
	if nameplate != null:
		nameplate.text = "Allié : Sloop"


func _refresh_cannon_points() -> void:
	var left_point := get_node_or_null("LeftCannonPoint") as Node3D
	if left_point != null:
		left_point.position = Vector3(-cannon_point_base_half_width, cannon_point_height, cannon_point_forward_offset)

	var right_point := get_node_or_null("RightCannonPoint") as Node3D
	if right_point != null:
		right_point.position = Vector3(cannon_point_base_half_width, cannon_point_height, cannon_point_forward_offset)


func _get_broadside_cannon_point(fire_direction: Vector3) -> Node3D:
	if fire_direction.length_squared() < 0.01:
		return null

	var right_direction: Vector3 = get_starboard_axis()
	if fire_direction.normalized().dot(right_direction) >= 0.0:
		return get_node_or_null("RightCannonPoint") as Node3D

	return get_node_or_null("LeftCannonPoint") as Node3D
