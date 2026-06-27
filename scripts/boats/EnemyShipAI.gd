extends Node

@export var detection_range: float = 55.0
@export var stop_distance: float = 7.0

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

	var offset := _player.global_position - ship.global_position
	offset.y = 0.0
	var distance_squared := offset.length_squared()
	var attack_range := _get_attack_range()

	if distance_squared > detection_range * detection_range:
		ship.brake(delta)
		return

	if distance_squared <= attack_range * attack_range:
		ship.brake(delta)
		_try_attack_player()
		return

	ship.steer_toward(_player.global_position, delta)


func _try_attack_player() -> void:
	if _attack_cooldown_remaining > 0.0 or _player == null:
		return

	var damage := 0
	if ship.has_method("get_contact_damage"):
		damage = ship.get_contact_damage()

	if damage <= 0 or not _player.has_method("take_damage"):
		return

	_player.take_damage(damage)
	_attack_cooldown_remaining = _get_attack_cooldown()


func _get_attack_range() -> float:
	if ship.has_method("get_attack_range"):
		return ship.get_attack_range()

	return stop_distance


func _get_attack_cooldown() -> float:
	if ship.has_method("get_attack_cooldown"):
		return ship.get_attack_cooldown()

	return 2.0
