extends Node3D

@export var creature_scene: PackedScene = preload("res://scenes/creatures/MarineCreature.tscn")
@export var max_creatures: int = 8
@export var initial_spawn_count: int = 5
@export var respawn_delay: float = 5.0
@export var spawn_check_interval: float = 2.4
@export var spawn_attempts_per_fill: int = 22
@export var min_player_spawn_distance: float = 18.0
@export var port_avoidance_distance: float = 42.0
@export var fallback_port_avoidance_distance: float = 28.0
@export var debug_creature_spawns: bool = false

var _active_creatures: Array[Node] = []
var _spawn_points: Array[Marker3D] = []
var _spawn_retry_scheduled: bool = false
var _spawn_check_timer: Timer


func _ready() -> void:
	add_to_group("marine_creature_spawner")
	_run_spawn_catalog_sanity_checks()
	_start_spawn_check_timer()
	call_deferred("_initialize_spawns")


func _initialize_spawns() -> void:
	_refresh_spawn_points()

	var target_initial_spawn_count: int = mini(initial_spawn_count, _get_target_creature_count())
	for i in range(target_initial_spawn_count):
		_spawn_creature_if_possible()

	_fill_spawn_slots()


func _start_spawn_check_timer() -> void:
	_spawn_check_timer = Timer.new()
	_spawn_check_timer.name = "CreatureSpawnCheckTimer"
	_spawn_check_timer.wait_time = maxf(0.5, spawn_check_interval)
	_spawn_check_timer.one_shot = false
	_spawn_check_timer.autostart = true
	_spawn_check_timer.timeout.connect(_fill_spawn_slots)
	add_child(_spawn_check_timer)


func _refresh_spawn_points() -> void:
	_spawn_points.clear()

	for node in get_tree().get_nodes_in_group("marine_creature_spawn_points"):
		if node is Marker3D:
			_spawn_points.append(node)


func _spawn_creature_if_possible() -> bool:
	_cleanup_inactive_creatures()

	var target_creature_count: int = _get_target_creature_count()
	if creature_scene == null:
		_debug_spawn("fail: marine creature scene missing")
		return false
	if _active_creatures.size() >= target_creature_count:
		_debug_spawn("skip: max marine creatures reached")
		return false

	var spawn_point: Marker3D = _pick_spawn_point()
	if spawn_point == null:
		_debug_spawn("fail: no valid marine creature spawn point")
		_schedule_spawn_retry()
		return false

	var spawn_zone_id: String = _get_spawn_point_zone(spawn_point)
	var creature_config: Dictionary = _pick_creature_config(spawn_zone_id)
	if creature_config.is_empty():
		_debug_spawn("fail: no marine creature config for zone %s" % spawn_zone_id)
		_schedule_spawn_retry()
		return false

	var creature: Node = creature_scene.instantiate()
	if not creature is Node3D:
		_debug_spawn("fail: marine creature scene did not instantiate Node3D")
		creature.queue_free()
		return false

	var creature_node: Node3D = creature as Node3D
	add_child(creature_node)
	creature_node.global_position = spawn_point.global_position
	creature_node.global_rotation = spawn_point.global_rotation

	if creature.has_method("configure_creature"):
		creature.call("configure_creature", creature_config, spawn_zone_id)

	_active_creatures.append(creature_node)
	if creature.has_signal("defeated"):
		creature.connect("defeated", Callable(self, "_on_creature_defeated").bind(creature))

	_debug_spawn("spawned %s in %s" % [
		String(creature_config.get("name", "Creature")),
		DangerZoneCatalog.get_zone_name(spawn_zone_id),
	])
	return true


func _pick_spawn_point() -> Marker3D:
	_refresh_spawn_points()
	if _spawn_points.is_empty():
		_debug_spawn("fail: no nodes in marine_creature_spawn_points group")
		return null

	var valid_points: Array[Marker3D] = _get_valid_spawn_points(port_avoidance_distance)
	if valid_points.is_empty() and fallback_port_avoidance_distance < port_avoidance_distance:
		_debug_spawn("retry: strict port avoidance rejected all marine creature points")
		valid_points = _get_valid_spawn_points(fallback_port_avoidance_distance)

	if valid_points.is_empty():
		_debug_spawn("fail: fallback port avoidance rejected all marine creature points")
		return null

	return _pick_weighted_spawn_point(valid_points)


func _get_valid_spawn_points(required_port_avoidance_distance: float) -> Array[Marker3D]:
	var valid_points: Array[Marker3D] = []
	for spawn_point in _spawn_points:
		var rejection_reason: String = _get_spawn_point_rejection_reason(spawn_point, required_port_avoidance_distance)
		if rejection_reason.is_empty():
			valid_points.append(spawn_point)
		else:
			_debug_spawn("reject %s: %s" % [spawn_point.name, rejection_reason])

	return valid_points


func _is_spawn_point_valid(spawn_point: Marker3D, required_port_avoidance_distance: float) -> bool:
	return _get_spawn_point_rejection_reason(spawn_point, required_port_avoidance_distance).is_empty()


func _get_spawn_point_rejection_reason(spawn_point: Marker3D, required_port_avoidance_distance: float) -> String:
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var player_distance: float = spawn_point.global_position.distance_to(player.global_position)
		if player_distance < min_player_spawn_distance:
			return "too close to player %.1f < %.1f" % [player_distance, min_player_spawn_distance]

	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var port_distance: float = spawn_point.global_position.distance_to(port_node.global_position)
		if port_distance < required_port_avoidance_distance:
			return "too close to port %s %.1f < %.1f" % [port_node.name, port_distance, required_port_avoidance_distance]

	return ""


func _pick_creature_config(zone_id: String) -> Dictionary:
	var normalized_zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id)
	var creature_ids: Array[String] = MarineCreatureCatalog.get_spawnable_creature_ids_for_zone(normalized_zone_id)
	if creature_ids.is_empty() and normalized_zone_id != DangerZoneCatalog.ZONE_SAFE:
		creature_ids = MarineCreatureCatalog.get_spawnable_creature_ids_for_zone(DangerZoneCatalog.ZONE_SAFE)

	var weighted_creature_ids: Array[String] = []

	for creature_id in creature_ids:
		var weight: int = MarineCreatureCatalog.get_spawn_weight(creature_id, normalized_zone_id)
		if weight <= 0 and normalized_zone_id != DangerZoneCatalog.ZONE_SAFE:
			weight = MarineCreatureCatalog.get_spawn_weight(creature_id, DangerZoneCatalog.ZONE_SAFE)
		weight = _apply_territory_creature_weight(weight, creature_id, normalized_zone_id)
		for i in range(weight):
			weighted_creature_ids.append(creature_id)

	if weighted_creature_ids.is_empty():
		return {}

	var picked_id: String = weighted_creature_ids.pick_random()
	return MarineCreatureCatalog.get_creature(picked_id)


func _on_creature_defeated(world_position: Vector3, creature_id: String, rewards: Dictionary, creature: Node) -> void:
	_active_creatures.erase(creature)
	_grant_creature_rewards(world_position, creature_id, rewards)
	_schedule_spawn_retry()


func _schedule_spawn_retry() -> void:
	if _spawn_retry_scheduled:
		return

	_spawn_retry_scheduled = true
	var timer: SceneTreeTimer = get_tree().create_timer(_get_respawn_delay())
	timer.timeout.connect(func() -> void:
		_spawn_retry_scheduled = false
		_fill_spawn_slots()
	)


func _fill_spawn_slots() -> void:
	_cleanup_inactive_creatures()

	var target_creature_count: int = _get_target_creature_count()
	var attempts_remaining: int = maxi(1, spawn_attempts_per_fill)
	while _active_creatures.size() < target_creature_count and attempts_remaining > 0:
		attempts_remaining -= 1
		_spawn_creature_if_possible()


func _cleanup_inactive_creatures() -> void:
	_active_creatures = _active_creatures.filter(func(creature: Node) -> bool:
		return is_instance_valid(creature)
	)


func _get_current_danger_zone_id() -> String:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_current_danger_zone_id_safe"):
		return DangerZoneCatalog.normalize_zone_id(String(game_state.call("get_current_danger_zone_id_safe")))
	if game_state != null and game_state.has_method("get_current_danger_zone_id"):
		return DangerZoneCatalog.normalize_zone_id(String(game_state.call("get_current_danger_zone_id")))

	return DangerZoneCatalog.ZONE_SAFE


func _get_target_creature_count() -> int:
	var zone_id: String = _get_current_danger_zone_id()
	var density: float = DangerZoneCatalog.get_marine_creature_density(zone_id)
	var territory_multiplier: float = _get_marine_creature_spawn_multiplier(zone_id)
	var target_count: int = roundi(float(max_creatures) * density * territory_multiplier)
	return clampi(target_count, 2, 12)


func _get_respawn_delay() -> float:
	var zone_id: String = _get_current_danger_zone_id()
	var density: float = DangerZoneCatalog.get_marine_creature_density(zone_id)
	var territory_multiplier: float = _get_marine_creature_spawn_multiplier(zone_id)
	var spawn_pressure: float = density * territory_multiplier
	return clampf(respawn_delay / maxf(0.6, spawn_pressure), 2.5, respawn_delay * 1.4)


func _get_spawn_point_zone(spawn_point: Marker3D) -> String:
	if spawn_point.has_method("get_danger_zone"):
		return DangerZoneCatalog.normalize_zone_id(String(spawn_point.call("get_danger_zone")))

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


func _apply_territory_creature_weight(base_weight: int, creature_id: String, zone_id_or_name: String) -> int:
	if base_weight <= 0:
		return 0

	var multiplier: float = _get_creature_spawn_weight_multiplier(zone_id_or_name, creature_id)
	return maxi(1, roundi(float(base_weight) * multiplier))


func _get_marine_creature_spawn_multiplier(zone_id_or_name: String) -> float:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_marine_creature_spawn_multiplier"):
		return clampf(float(game_state.call("get_marine_creature_spawn_multiplier", zone_id_or_name)), 0.65, 1.45)

	return 1.0


func _get_creature_spawn_weight_multiplier(zone_id_or_name: String, creature_id: String) -> float:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_creature_spawn_weight_multiplier"):
		return clampf(float(game_state.call("get_creature_spawn_weight_multiplier", zone_id_or_name, creature_id)), 0.70, 1.55)

	return 1.0


func _debug_spawn(message: String) -> void:
	if not debug_creature_spawns:
		return

	print(
		"MarineCreatureSpawner: %s | active=%d/%d points=%d current_zone=%s"
		% [
			message,
			_active_creatures.size(),
			_get_target_creature_count(),
			_spawn_points.size(),
			DangerZoneCatalog.get_zone_name(_get_current_danger_zone_id()),
		]
	)


func _run_spawn_catalog_sanity_checks() -> void:
	if not debug_creature_spawns:
		return

	var checked_zones: Array[String] = [
		DangerZoneCatalog.ZONE_SAFE,
		DangerZoneCatalog.ZONE_WATCHED,
		DangerZoneCatalog.ZONE_CONTESTED,
		DangerZoneCatalog.ZONE_HOSTILE,
		DangerZoneCatalog.ZONE_DEADLY,
	]
	for zone_id in checked_zones:
		var creature_ids: Array[String] = MarineCreatureCatalog.get_spawnable_creature_ids_for_zone(zone_id)
		if creature_ids.is_empty():
			print("Spawn sanity: no marine creatures for %s" % zone_id)
			continue

		for creature_id in creature_ids:
			if not MarineCreatureCatalog.has_creature(creature_id):
				print("Spawn sanity: unknown marine creature '%s' in %s" % [creature_id, zone_id])
			elif not MarineCreatureCatalog.is_creature_implemented(creature_id):
				print("Spawn sanity: unimplemented marine creature '%s' in %s" % [creature_id, zone_id])


func _grant_creature_rewards(_world_position: Vector3, creature_id: String, rewards: Dictionary) -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_marine_creature_defeated"):
		game_state.call("record_marine_creature_defeated", creature_id)

	var reward_messages: Array[String] = ["%s vaincu" % MarineCreatureCatalog.get_creature_name(creature_id)]
	var gold_reward: int = maxi(0, int(rewards.get("gold", 0)))
	var wood_reward: int = maxi(0, int(rewards.get("wood", 0)))
	var creature_level: int = MarineCreatureCatalog.get_creature_level(creature_id)
	if game_state != null and creature_level >= 2 and game_state.has_method("get_player_dangerous_creature_reward_multiplier"):
		var reward_multiplier: float = float(game_state.call("get_player_dangerous_creature_reward_multiplier"))
		gold_reward = maxi(0, roundi(float(gold_reward) * reward_multiplier))
	if game_state != null and game_state.has_method("add_resources") and (gold_reward > 0 or wood_reward > 0):
		game_state.call("add_resources", gold_reward, wood_reward)
		if gold_reward > 0:
			reward_messages.append("+%d or" % gold_reward)
		if wood_reward > 0:
			reward_messages.append("+%d bois" % wood_reward)

	var map_fragments: int = maxi(0, int(rewards.get("map_fragments", 0)))
	if game_state != null and game_state.has_method("add_treasure_resources") and map_fragments > 0:
		game_state.call("add_treasure_resources", map_fragments, 0, true)
		reward_messages.append("+%d fragment" % map_fragments)

	var rare_resource_id: String = String(rewards.get("rare_resource_id", ""))
	var rare_resource_amount: int = maxi(0, int(rewards.get("rare_resource_amount", 0)))
	var rare_resource_chance: float = clampf(float(rewards.get("rare_resource_chance", 0.0)), 0.0, 1.0)
	if game_state != null and game_state.has_method("get_player_rare_creature_resource_multiplier"):
		var rare_multiplier: float = float(game_state.call("get_player_rare_creature_resource_multiplier"))
		rare_resource_chance = clampf(rare_resource_chance * rare_multiplier, 0.0, 1.0)
	if not rare_resource_id.is_empty() and rare_resource_amount > 0 and randf() <= rare_resource_chance:
		if game_state != null and game_state.has_method("add_creature_resource"):
			game_state.call("add_creature_resource", rare_resource_id, rare_resource_amount)
			reward_messages.append("Ressource gagnee : %s x%d" % [
				MarineCreatureCatalog.get_resource_name(rare_resource_id),
				rare_resource_amount,
			])

	var renown_reward: int = maxi(0, int(rewards.get("renown", 0)))
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("add_reputation") and renown_reward > 0:
		reputation_system.call("add_reputation", renown_reward, "marine_creature_defeated")
		reward_messages.append("+%d renom" % renown_reward)

	_show_reward_feedback(reward_messages)


func _show_reward_feedback(reward_messages: Array[String]) -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.call("show_temporary_context_message", "\n".join(reward_messages), 2.2)
