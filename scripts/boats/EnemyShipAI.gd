extends Node

@export var detection_range: float = 55.0
@export var stop_distance: float = 7.0

@onready var ship: EnemyShip = get_parent() as EnemyShip

var _player: Node3D


func _physics_process(delta: float) -> void:
	if ship == null:
		return

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D

	if _player == null:
		ship.brake(delta)
		return

	var offset := _player.global_position - ship.global_position
	offset.y = 0.0
	var distance_squared := offset.length_squared()

	if distance_squared > detection_range * detection_range:
		ship.brake(delta)
		return

	if distance_squared <= stop_distance * stop_distance:
		ship.brake(delta)
		return

	ship.steer_toward(_player.global_position, delta)
