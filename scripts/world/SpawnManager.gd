extends Node3D

@export var enemy_scene: PackedScene = preload("res://scenes/boats/EnemyShip.tscn")
@export var max_enemies: int = 5
@export var initial_spawn_count: int = 3
@export var respawn_delay: float = 5.0
@export var spawn_check_interval: float = 2.5
@export var min_player_spawn_distance: float = 22.0
@export var port_avoidance_distance: float = 45.0
@export var fallback_port_avoidance_distance: float = 28.0
@export var debug_spawns: bool = false

var _active_enemies: Array[Node] = []
var _spawn_points: Array[Marker3D] = []
var _spawn_retry_scheduled: bool = false
var _spawn_check_timer: Timer


func _ready() -> void:
	add_to_group("spawn_manager")
	_run_spawn_catalog_sanity_checks()
	_start_spawn_check_timer()
	call_deferred("_initialize_spawns")


func _initialize_spawns() -> void:
	_refresh_spawn_points()

	var target_initial_spawn_count: int = mini(initial_spawn_count, _get_target_enemy_count())
	for i in range(target_initial_spawn_count):
		_spawn_enemy_if_possible()

	_fill_spawn_slots()


func _start_spawn_check_timer() -> void:
	_spawn_check_timer = Timer.new()
	_spawn_check_timer.name = "SpawnCheckTimer"
	_spawn_check_timer.wait_time = maxf(0.5, spawn_check_interval)
	_spawn_check_timer.one_shot = false
	_spawn_check_timer.autostart = true
	_spawn_check_timer.timeout.connect(_fill_spawn_slots)
	add_child(_spawn_check_timer)


func _refresh_spawn_points() -> void:
	_spawn_points.clear()

	for node in get_tree().get_nodes_in_group("enemy_spawn_points"):
		if node is Marker3D:
			_spawn_points.append(node)


func _spawn_enemy_if_possible() -> bool:
	_cleanup_inactive_enemies()

	var target_enemy_count: int = _get_target_enemy_count()
	if enemy_scene == null:
		_debug_spawn("fail: enemy scene missing")
		return false
	if _active_enemies.size() >= target_enemy_count:
		_debug_spawn("skip: max enemies reached")
		return false

	var spawn_point := _pick_spawn_point()
	if spawn_point == null:
		_debug_spawn("fail: no valid enemy spawn point")
		_schedule_spawn_retry()
		return false

	var enemy := enemy_scene.instantiate()
	if not enemy is Node3D:
		_debug_spawn("fail: enemy scene did not instantiate Node3D")
		enemy.queue_free()
		return false

	var spawn_zone_id: String = _get_spawn_point_zone(spawn_point)
	var variant_config: Dictionary = _pick_enemy_variant(spawn_zone_id)
	if variant_config.is_empty():
		_debug_spawn("fail: no enemy variant for zone %s" % spawn_zone_id)
		_schedule_spawn_retry()
		return false

	variant_config = _apply_zone_reward_multiplier(variant_config, spawn_zone_id)
	if enemy.has_method("configure_variant"):
		enemy.configure_variant(variant_config)

	var enemy_node := enemy as Node3D
	add_child(enemy_node)
	enemy_node.global_position = spawn_point.global_position
	enemy_node.global_rotation = spawn_point.global_rotation
	_active_enemies.append(enemy_node)

	if enemy.has_signal("destroyed"):
		enemy.connect("destroyed", Callable(self, "_on_enemy_destroyed").bind(enemy))

	_debug_spawn("spawned %s in %s" % [
		String(variant_config.get("display_name", "Ennemi")),
		DangerZoneCatalog.get_zone_name(spawn_zone_id),
	])
	return true


func _pick_spawn_point() -> Marker3D:
	_refresh_spawn_points()
	if _spawn_points.is_empty():
		_debug_spawn("fail: no nodes in enemy_spawn_points group")
		return null

	var valid_points: Array[Marker3D] = _get_valid_spawn_points(port_avoidance_distance)
	if valid_points.is_empty() and fallback_port_avoidance_distance < port_avoidance_distance:
		_debug_spawn("retry: strict port avoidance rejected all enemy points")
		valid_points = _get_valid_spawn_points(fallback_port_avoidance_distance)

	if valid_points.is_empty():
		_debug_spawn("fail: fallback port avoidance rejected all enemy points")
		return null

	return _pick_weighted_spawn_point(valid_points)


func _get_valid_spawn_points(required_port_avoidance_distance: float) -> Array[Marker3D]:
	var valid_points: Array[Marker3D] = []
	for spawn_point in _spawn_points:
		if _is_spawn_point_valid(spawn_point, required_port_avoidance_distance):
			valid_points.append(spawn_point)

	return valid_points


func _is_spawn_point_valid(spawn_point: Marker3D, required_port_avoidance_distance: float) -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var player_distance := spawn_point.global_position.distance_to(player.global_position)
		if player_distance < min_player_spawn_distance:
			return false

	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var port_distance: float = spawn_point.global_position.distance_to(port_node.global_position)
		if port_distance < required_port_avoidance_distance:
			return false

	return true


func _on_enemy_destroyed(_world_position: Vector3, _gold_reward: int, _wood_reward: int, enemy: Node) -> void:
	_active_enemies.erase(enemy)
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_enemy_destroyed"):
		game_state.record_enemy_destroyed()
	_record_enemy_reputation(enemy)
	_schedule_spawn_retry()


func _schedule_spawn_retry() -> void:
	if _spawn_retry_scheduled:
		return

	_spawn_retry_scheduled = true
	var timer := get_tree().create_timer(_get_respawn_delay())
	timer.timeout.connect(func() -> void:
		_spawn_retry_scheduled = false
		_fill_spawn_slots()
	)


func _fill_spawn_slots() -> void:
	_cleanup_inactive_enemies()

	var target_enemy_count: int = _get_target_enemy_count()
	while _active_enemies.size() < target_enemy_count:
		if not _spawn_enemy_if_possible():
			break


func _cleanup_inactive_enemies() -> void:
	_active_enemies = _active_enemies.filter(func(enemy: Node) -> bool:
		return is_instance_valid(enemy)
	)


func _record_enemy_reputation(enemy: Node) -> void:
	var reputation_system := get_node_or_null("/root/ReputationSystem")
	if reputation_system == null or not reputation_system.has_method("record_enemy_destroyed"):
		return

	var enemy_type_id := ""
	if enemy != null and enemy.has_method("get_enemy_type_id"):
		enemy_type_id = String(enemy.get_enemy_type_id())

	reputation_system.record_enemy_destroyed(enemy_type_id)


func _pick_enemy_variant(danger_zone: String) -> Dictionary:
	var variants := _get_enemy_variants()
	var weighted_variants: Array[Dictionary] = []
	var danger_level := _get_danger_level()
	if variants.is_empty():
		return {}

	for config in variants:
		var variant_id := String(config.get("id", ""))
		var weight := _get_variant_weight(variant_id, danger_level, danger_zone)
		for i in range(weight):
			weighted_variants.append(config)

	if weighted_variants.is_empty():
		return variants.pick_random()

	return weighted_variants.pick_random()


func _apply_zone_reward_multiplier(config: Dictionary, zone_id: String) -> Dictionary:
	var adjusted_config: Dictionary = config.duplicate(true)
	var reward_multiplier: float = DangerZoneCatalog.get_reward_multiplier(zone_id)
	var gold_reward: int = maxi(0, int(adjusted_config.get("reward_gold", 0)))
	var wood_reward: int = maxi(0, int(adjusted_config.get("reward_wood", 0)))

	adjusted_config["reward_gold"] = roundi(float(gold_reward) * reward_multiplier)
	adjusted_config["reward_wood"] = roundi(float(wood_reward) * reward_multiplier)
	adjusted_config["danger_zone"] = zone_id
	adjusted_config["reward_multiplier"] = reward_multiplier
	return adjusted_config


func _get_enemy_variants() -> Array[Dictionary]:
	var variants: Array[Dictionary] = []
	variants.append({
		"id": "small_pirate",
		"display_name": "Petit pirate",
		"max_health": 35,
		"move_speed": 8.0,
		"chase_speed_multiplier": 1.10,
		"turn_speed": 2.2,
		"turn_acceleration": 4.0,
		"turn_deceleration": 4.8,
		"contact_damage": 5,
		"attack_range": 32.0,
		"attack_cooldown": 1.8,
		"detection_range": 50.0,
		"chase_leash_distance": 100.0,
		"reward_gold": 8,
		"reward_wood": 5,
		"visual_scale": 0.74,
		"hull_scale": Vector3(0.82, 0.86, 0.82),
		"deck_scale": Vector3(0.8, 1.0, 0.72),
		"mast_scale": Vector3(0.9, 0.88, 0.9),
		"sail_scale": Vector3(0.75, 0.85, 1.0),
		"hull_color": Color(0.68, 0.23, 0.11, 1.0),
		"sail_color": Color(0.78, 0.63, 0.36, 1.0),
		"visual_style": "small",
		"nameplate_height": 2.45,
	})
	variants.append({
		"id": "brigantine",
		"display_name": "Brigantin pirate",
		"max_health": 65,
		"move_speed": 6.5,
		"chase_speed_multiplier": 1.15,
		"turn_speed": 1.5,
		"turn_acceleration": 2.8,
		"turn_deceleration": 3.2,
		"contact_damage": 10,
		"attack_range": 38.0,
		"attack_cooldown": 2.2,
		"detection_range": 60.0,
		"chase_leash_distance": 120.0,
		"reward_gold": 16,
		"reward_wood": 10,
		"visual_scale": 1.0,
		"hull_scale": Vector3(1.0, 1.0, 1.12),
		"deck_scale": Vector3(1.0, 1.0, 1.08),
		"mast_scale": Vector3(1.0, 1.0, 1.0),
		"sail_scale": Vector3(1.0, 1.0, 1.0),
		"hull_color": Color(0.42, 0.08, 0.06, 1.0),
		"sail_color": Color(0.12, 0.11, 0.10, 1.0),
		"visual_style": "brigantine",
		"nameplate_height": 3.1,
	})
	variants.append({
		"id": "heavy_patrol",
		"display_name": "Patrouilleur lourd",
		"max_health": 115,
		"move_speed": 5.0,
		"chase_speed_multiplier": 1.20,
		"turn_speed": 0.9,
		"turn_acceleration": 1.8,
		"turn_deceleration": 2.2,
		"contact_damage": 18,
		"attack_range": 45.0,
		"attack_cooldown": 2.8,
		"detection_range": 70.0,
		"chase_leash_distance": 140.0,
		"reward_gold": 30,
		"reward_wood": 18,
		"visual_scale": 1.2,
		"hull_scale": Vector3(1.25, 1.18, 1.12),
		"deck_scale": Vector3(1.18, 1.0, 1.0),
		"mast_scale": Vector3(1.1, 1.18, 1.1),
		"sail_scale": Vector3(1.08, 1.1, 1.0),
		"hull_color": Color(0.16, 0.18, 0.23, 1.0),
		"sail_color": Color(0.28, 0.27, 0.24, 1.0),
		"visual_style": "heavy",
		"nameplate_height": 3.75,
	})
	return variants


func _get_enemy_variant_ids() -> Array[String]:
	var ids: Array[String] = []
	for variant in _get_enemy_variants():
		ids.append(String(variant.get("id", "")))

	return ids


func _get_danger_level() -> int:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_danger_level"):
		return game_state.get_danger_level()

	return 1


func _get_current_danger_zone_id() -> String:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_current_danger_zone_id_safe"):
		return DangerZoneCatalog.normalize_zone_id(String(game_state.call("get_current_danger_zone_id_safe")))
	if game_state != null and game_state.has_method("get_current_danger_zone_id"):
		return DangerZoneCatalog.normalize_zone_id(String(game_state.call("get_current_danger_zone_id")))

	return DangerZoneCatalog.ZONE_SAFE


func _get_target_enemy_count() -> int:
	var zone_id: String = _get_current_danger_zone_id()
	var density: float = DangerZoneCatalog.get_enemy_density(zone_id)
	var target_count: int = roundi(float(max_enemies) * density)
	return clampi(target_count, 1, 12)


func _get_respawn_delay() -> float:
	var zone_id: String = _get_current_danger_zone_id()
	var density: float = DangerZoneCatalog.get_enemy_density(zone_id)
	return clampf(respawn_delay / maxf(0.5, density), 2.5, respawn_delay * 1.5)


func _get_spawn_point_zone(spawn_point: Marker3D) -> String:
	if spawn_point.has_method("get_danger_zone"):
		return DangerZoneCatalog.normalize_zone_id(String(spawn_point.get_danger_zone()))

	return DangerZoneCatalog.ZONE_SAFE


func _pick_weighted_spawn_point(valid_points: Array[Marker3D]) -> Marker3D:
	var weighted_points: Array[Marker3D] = []
	for spawn_point in valid_points:
		var weight: int = _get_spawn_point_weight(spawn_point)
		for i in range(weight):
			weighted_points.append(spawn_point)

	if weighted_points.is_empty():
		return valid_points.pick_random()

	return weighted_points.pick_random()


func _get_spawn_point_weight(spawn_point: Marker3D) -> int:
	var current_zone_id: String = _get_current_danger_zone_id()
	var spawn_zone_id: String = _get_spawn_point_zone(spawn_point)
	var current_level: int = DangerZoneCatalog.get_zone_level(current_zone_id)
	var spawn_level: int = DangerZoneCatalog.get_zone_level(spawn_zone_id)
	var level_distance: int = absi(current_level - spawn_level)

	if spawn_zone_id == current_zone_id:
		return 5
	if level_distance == 1:
		return 2

	return 1


func _get_variant_weight(variant_id: String, danger_level: int, danger_zone: String) -> int:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(danger_zone)
	var allowed_enemy_types: Array[String] = DangerZoneCatalog.get_enemy_types(zone_id)
	if not allowed_enemy_types.has(variant_id):
		return 0

	match zone_id:
		DangerZoneCatalog.ZONE_SAFE:
			match variant_id:
				"small_pirate":
					return 10
		DangerZoneCatalog.ZONE_WATCHED:
			match variant_id:
				"small_pirate":
					return maxi(3, 7 - danger_level)
				"brigantine":
					return 2 + mini(danger_level, 3)
		DangerZoneCatalog.ZONE_CONTESTED:
			match variant_id:
				"small_pirate":
					return maxi(1, 4 - danger_level)
				"brigantine":
					return 6
				"heavy_patrol":
					return maxi(1, danger_level)
		DangerZoneCatalog.ZONE_HOSTILE:
			match variant_id:
				"brigantine":
					return 5
				"heavy_patrol":
					return 3 + danger_level
		DangerZoneCatalog.ZONE_DEADLY:
			match variant_id:
				"brigantine":
					return 2
				"heavy_patrol":
					return 7 + danger_level
		DangerZoneCatalog.ZONE_LEGENDARY:
			match variant_id:
				"heavy_patrol":
					return 10 + danger_level
		DangerZoneCatalog.ZONE_ABYSS:
			match variant_id:
				"heavy_patrol":
					return 12 + danger_level

	return 1


func _debug_spawn(message: String) -> void:
	if not debug_spawns:
		return

	print(
		"SpawnManager: %s | active=%d/%d points=%d current_zone=%s"
		% [
			message,
			_active_enemies.size(),
			_get_target_enemy_count(),
			_spawn_points.size(),
			DangerZoneCatalog.get_zone_name(_get_current_danger_zone_id()),
		]
	)


func _run_spawn_catalog_sanity_checks() -> void:
	if not debug_spawns:
		return

	var known_enemy_ids: Array[String] = _get_enemy_variant_ids()
	for zone_id in DangerZoneCatalog.get_zone_ids():
		var enemy_types: Array[String] = DangerZoneCatalog.get_enemy_types(zone_id)
		if enemy_types.is_empty():
			print("Spawn sanity: no pirate enemy types for %s" % zone_id)
			continue

		for enemy_type in enemy_types:
			if not known_enemy_ids.has(enemy_type):
				print("Spawn sanity: unknown pirate enemy type '%s' in %s" % [enemy_type, zone_id])
