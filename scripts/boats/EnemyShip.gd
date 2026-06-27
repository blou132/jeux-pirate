class_name EnemyShip
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal destroyed(world_position: Vector3, gold_reward: int, wood_reward: int)

@export var max_health: int = 60
@export var move_speed: float = 7.0
@export var turn_speed: float = 1.15
@export var reward_gold: int = 12
@export var reward_wood: int = 8

var health: int
var _destroyed: bool = false


func _ready() -> void:
	health = max_health
	add_to_group("enemy_ships")
	health_changed.emit(health, max_health)


func steer_toward(target_position: Vector3, delta: float) -> void:
	if _destroyed:
		return

	var to_target := target_position - global_position
	to_target.y = 0.0

	if to_target.length_squared() < 0.25:
		brake(delta)
		return

	var desired_forward := to_target.normalized()
	var current_forward := -global_transform.basis.z
	var signed_angle := current_forward.signed_angle_to(desired_forward, Vector3.UP)
	var turn_amount := clampf(signed_angle, -turn_speed * delta, turn_speed * delta)

	rotate_y(turn_amount)
	velocity = -global_transform.basis.z * move_speed
	move_and_slide()
	global_position.y = 0.0


func brake(delta: float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
	move_and_slide()
	global_position.y = 0.0


func take_damage(amount: int) -> void:
	if _destroyed:
		return

	health = clampi(health - amount, 0, max_health)
	health_changed.emit(health, max_health)

	if health <= 0:
		_destroy()


func _destroy() -> void:
	_destroyed = true
	var sink_position := global_position
	var loot_system := get_tree().get_first_node_in_group("loot_system")
	if loot_system != null and loot_system.has_method("drop_from_ship"):
		loot_system.drop_from_ship(sink_position, reward_gold, reward_wood)

	destroyed.emit(sink_position, reward_gold, reward_wood)
	queue_free()
