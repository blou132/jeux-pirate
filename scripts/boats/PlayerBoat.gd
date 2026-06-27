class_name PlayerBoat
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal speed_changed(speed: float)

@export var max_health: int = 100
@export var max_forward_speed: float = 7.0
@export var max_reverse_speed: float = 5.0
@export var acceleration: float = 12.0
@export var reverse_acceleration: float = 8.0
@export var drag: float = 6.0
@export var turn_speed: float = 1.7
@export var hull_health_bonus_per_level: int = 25
@export var sail_speed_bonus_per_level: float = 1.0

var health: int
var current_speed: float = 0.0
var _base_max_health: int
var _base_max_forward_speed: float


func _ready() -> void:
	_base_max_health = max_health
	_base_max_forward_speed = max_forward_speed
	health = max_health
	add_to_group("player")
	_connect_upgrade_system()
	health_changed.emit(health, max_health)
	speed_changed.emit(current_speed)


func _physics_process(delta: float) -> void:
	var throttle := _get_throttle()

	if throttle > 0.0:
		current_speed = move_toward(current_speed, max_forward_speed, acceleration * delta)
	elif throttle < 0.0:
		current_speed = move_toward(current_speed, -max_reverse_speed, reverse_acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, drag * delta)

	_apply_turn(delta)
	velocity = -global_transform.basis.z * current_speed
	move_and_slide()
	global_position.y = 0.0

	speed_changed.emit(current_speed)


func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health = clampi(health - amount, 0, max_health)
	health_changed.emit(health, max_health)


func repair(amount: int) -> int:
	if amount <= 0 or health >= max_health:
		return 0

	var previous_health := health
	health = clampi(health + amount, 0, max_health)
	health_changed.emit(health, max_health)
	return health - previous_health


func is_at_max_health() -> bool:
	return health >= max_health


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_current_speed() -> float:
	return current_speed


func _get_throttle() -> float:
	var throttle := 0.0

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z):
		throttle += 1.0
	if Input.is_key_pressed(KEY_S):
		throttle -= 1.0

	return throttle


func _apply_turn(delta: float) -> void:
	var turn_input := 0.0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q):
		turn_input += 1.0
	if Input.is_key_pressed(KEY_D):
		turn_input -= 1.0

	if is_zero_approx(turn_input) or absf(current_speed) < 0.05:
		return

	var speed_factor := clampf(absf(current_speed) / max_forward_speed, 0.25, 1.0)
	var direction_factor := 1.0
	if current_speed < 0.0:
		direction_factor = -1.0

	rotate_y(turn_input * turn_speed * speed_factor * direction_factor * delta)


func _connect_upgrade_system() -> void:
	var upgrade_system := get_node_or_null("/root/UpgradeSystem")
	if upgrade_system == null:
		return

	var callback := Callable(self, "_on_upgrades_changed")
	if upgrade_system.has_signal("upgrades_changed") and not upgrade_system.is_connected("upgrades_changed", callback):
		upgrade_system.connect("upgrades_changed", callback)

	if upgrade_system.has_method("get_hull_level") and upgrade_system.has_method("get_sails_level") and upgrade_system.has_method("get_cannons_level"):
		_on_upgrades_changed(
			upgrade_system.get_hull_level(),
			upgrade_system.get_sails_level(),
			upgrade_system.get_cannons_level()
		)


func _on_upgrades_changed(hull_level: int, sails_level: int, _cannons_level: int) -> void:
	var previous_max_health := max_health
	max_health = _base_max_health + (hull_level * hull_health_bonus_per_level)
	max_forward_speed = _base_max_forward_speed + (sails_level * sail_speed_bonus_per_level)

	if max_health > previous_max_health:
		health += max_health - previous_max_health

	health = clampi(health, 0, max_health)
	health_changed.emit(health, max_health)
