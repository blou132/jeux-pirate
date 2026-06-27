extends Node

@export var enemy_cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/EnemyCannonBall.tscn")
@export var detection_range: float = 55.0
@export var stop_distance: float = 7.0
@export var projectile_speed: float = 13.0

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

	if _player.has_method("is_destroyed") and _player.is_destroyed():
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

	if damage <= 0:
		return

	_fire_projectile(damage)
	_attack_cooldown_remaining = _get_attack_cooldown()


func _get_attack_range() -> float:
	if ship.has_method("get_attack_range"):
		return ship.get_attack_range()

	return stop_distance


func _get_attack_cooldown() -> float:
	if ship.has_method("get_attack_cooldown"):
		return ship.get_attack_cooldown()

	return 2.0


func _fire_projectile(damage: int) -> void:
	if enemy_cannon_ball_scene == null or not is_instance_valid(_player):
		return

	var projectile := enemy_cannon_ball_scene.instantiate()
	if not projectile is Node3D:
		projectile.queue_free()
		return

	var projectile_node := projectile as Node3D
	var start_position := ship.global_position + Vector3(0.0, 0.7, 0.0)
	var target_position := _player.global_position + Vector3(0.0, 0.45, 0.0)
	var direction := target_position - start_position
	direction.y = clampf(direction.y, -0.2, 0.35)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile)

	projectile_node.global_position = start_position

	if projectile.has_method("launch"):
		projectile.launch(direction, ship, projectile_speed, damage)
