extends Node3D

@export var enemy_scene: PackedScene = preload("res://scenes/boats/EnemyShip.tscn")
@export var max_enemies: int = 4
@export var initial_spawn_count: int = 3
@export var respawn_delay: float = 6.0
@export var min_player_spawn_distance: float = 22.0
@export var port_avoidance_distance: float = 18.0

var _active_enemies: Array[Node] = []
var _spawn_points: Array[Marker3D] = []
var _spawn_retry_scheduled: bool = false


func _ready() -> void:
	add_to_group("spawn_manager")
	call_deferred("_initialize_spawns")


func _initialize_spawns() -> void:
	_refresh_spawn_points()

	for i in range(initial_spawn_count):
		_spawn_enemy_if_possible()


func _refresh_spawn_points() -> void:
	_spawn_points.clear()

	for node in get_tree().get_nodes_in_group("enemy_spawn_points"):
		if node is Marker3D:
			_spawn_points.append(node)


func _spawn_enemy_if_possible() -> bool:
	_cleanup_inactive_enemies()

	if enemy_scene == null or _active_enemies.size() >= max_enemies:
		return false

	var spawn_point := _pick_spawn_point()
	if spawn_point == null:
		_schedule_spawn_retry()
		return false

	var enemy := enemy_scene.instantiate()
	if not enemy is Node3D:
		enemy.queue_free()
		return false

	var enemy_node := enemy as Node3D
	add_child(enemy_node)
	enemy_node.global_position = spawn_point.global_position
	enemy_node.global_rotation = spawn_point.global_rotation
	_active_enemies.append(enemy_node)

	if enemy.has_signal("destroyed"):
		enemy.connect("destroyed", Callable(self, "_on_enemy_destroyed").bind(enemy))

	return true


func _pick_spawn_point() -> Marker3D:
	_refresh_spawn_points()
	var valid_points: Array[Marker3D] = []

	for spawn_point in _spawn_points:
		if _is_spawn_point_valid(spawn_point):
			valid_points.append(spawn_point)

	if valid_points.is_empty():
		return null

	return valid_points.pick_random()


func _is_spawn_point_valid(spawn_point: Marker3D) -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var player_distance := spawn_point.global_position.distance_to(player.global_position)
		if player_distance < min_player_spawn_distance:
			return false

	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		var port_distance := spawn_point.global_position.distance_to(port.global_position)
		if port_distance < port_avoidance_distance:
			return false

	return true


func _on_enemy_destroyed(_world_position: Vector3, _gold_reward: int, _wood_reward: int, enemy: Node) -> void:
	_active_enemies.erase(enemy)
	_schedule_spawn_retry()


func _schedule_spawn_retry() -> void:
	if _spawn_retry_scheduled:
		return

	_spawn_retry_scheduled = true
	var timer := get_tree().create_timer(respawn_delay)
	timer.timeout.connect(func() -> void:
		_spawn_retry_scheduled = false
		_fill_spawn_slots()
	)


func _fill_spawn_slots() -> void:
	_cleanup_inactive_enemies()

	while _active_enemies.size() < max_enemies:
		if not _spawn_enemy_if_possible():
			break


func _cleanup_inactive_enemies() -> void:
	_active_enemies = _active_enemies.filter(func(enemy: Node) -> bool:
		return is_instance_valid(enemy)
	)
