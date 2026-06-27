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

	var variant_config := _pick_enemy_variant(_get_spawn_point_zone(spawn_point))
	if enemy.has_method("configure_variant"):
		enemy.configure_variant(variant_config)

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
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_enemy_destroyed"):
		game_state.record_enemy_destroyed()
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


func _pick_enemy_variant(danger_zone: String) -> Dictionary:
	var variants := _get_enemy_variants()
	var weighted_variants: Array[Dictionary] = []
	var danger_level := _get_danger_level()

	for config in variants:
		var variant_id := String(config.get("id", ""))
		var weight := _get_variant_weight(variant_id, danger_level, danger_zone)
		for i in range(weight):
			weighted_variants.append(config)

	if weighted_variants.is_empty():
		return variants.pick_random()

	return weighted_variants.pick_random()


func _get_enemy_variants() -> Array[Dictionary]:
	var variants: Array[Dictionary] = []
	variants.append({
		"id": "small_pirate",
		"display_name": "Petit pirate",
		"max_health": 35,
		"move_speed": 9.0,
		"turn_speed": 1.45,
		"contact_damage": 6,
		"reward_gold": 8,
		"reward_wood": 5,
		"visual_scale": 0.82,
		"hull_color": Color(0.55, 0.14, 0.08, 1.0),
		"sail_color": Color(0.18, 0.16, 0.12, 1.0),
	})
	variants.append({
		"id": "brigantine",
		"display_name": "Brigantin pirate",
		"max_health": 65,
		"move_speed": 7.2,
		"turn_speed": 1.15,
		"contact_damage": 12,
		"reward_gold": 16,
		"reward_wood": 10,
		"visual_scale": 1.0,
		"hull_color": Color(0.42, 0.08, 0.06, 1.0),
		"sail_color": Color(0.12, 0.11, 0.10, 1.0),
	})
	variants.append({
		"id": "heavy_patrol",
		"display_name": "Patrouilleur lourd",
		"max_health": 115,
		"move_speed": 5.2,
		"turn_speed": 0.82,
		"contact_damage": 22,
		"reward_gold": 30,
		"reward_wood": 18,
		"visual_scale": 1.18,
		"hull_color": Color(0.16, 0.18, 0.23, 1.0),
		"sail_color": Color(0.28, 0.27, 0.24, 1.0),
	})
	return variants


func _get_danger_level() -> int:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_danger_level"):
		return game_state.get_danger_level()

	return 1


func _get_spawn_point_zone(spawn_point: Marker3D) -> String:
	if spawn_point.has_method("get_danger_zone"):
		return spawn_point.get_danger_zone()

	return "open"


func _get_variant_weight(variant_id: String, danger_level: int, danger_zone: String) -> int:
	match danger_zone:
		"port":
			match variant_id:
				"small_pirate":
					return 8
				"brigantine":
					return 1 + mini(danger_level, 2)
				"heavy_patrol":
					return 0
		"archipelago":
			match variant_id:
				"small_pirate":
					return max(2, 6 - danger_level)
				"brigantine":
					return 4 + danger_level
				"heavy_patrol":
					return max(0, danger_level - 2)
		"hostile":
			match variant_id:
				"small_pirate":
					return max(1, 4 - danger_level)
				"brigantine":
					return 4
				"heavy_patrol":
					return 2 + danger_level

	if danger_level <= 1:
		match variant_id:
			"small_pirate":
				return 7
			"brigantine":
				return 2
			"heavy_patrol":
				return 0
	elif danger_level == 2:
		match variant_id:
			"small_pirate":
				return 5
			"brigantine":
				return 4
			"heavy_patrol":
				return 1
	elif danger_level == 3:
		match variant_id:
			"small_pirate":
				return 3
			"brigantine":
				return 5
			"heavy_patrol":
				return 2

	match variant_id:
		"small_pirate":
			return 2
		"brigantine":
			return 5
		"heavy_patrol":
			return 4

	return 1
