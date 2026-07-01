extends Node3D

@export var creature_scene: PackedScene = preload("res://scenes/creatures/MarineCreature.tscn")
@export var max_creatures: int = 4
@export var initial_spawn_count: int = 2
@export var respawn_delay: float = 7.0
@export var spawn_check_interval: float = 3.0
@export var min_player_spawn_distance: float = 18.0
@export var port_avoidance_distance: float = 48.0
@export var debug_creature_spawns: bool = false

var _active_creatures: Array[Node] = []
var _spawn_points: Array[Marker3D] = []
var _spawn_retry_scheduled: bool = false
var _spawn_check_timer: Timer


func _ready() -> void:
	add_to_group("marine_creature_spawner")
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
		return false
	if _active_creatures.size() >= target_creature_count:
		return false

	var spawn_point: Marker3D = _pick_spawn_point()
	if spawn_point == null:
		_schedule_spawn_retry()
		return false

	var spawn_zone_id: String = _get_spawn_point_zone(spawn_point)
	var creature_config: Dictionary = _pick_creature_config(spawn_zone_id)
	if creature_config.is_empty():
		_schedule_spawn_retry()
		return false

	var creature: Node = creature_scene.instantiate()
	if not creature is Node3D:
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

	_debug_spawn(creature_config, spawn_zone_id)
	return true


func _pick_spawn_point() -> Marker3D:
	_refresh_spawn_points()
	var valid_points: Array[Marker3D] = []

	for spawn_point in _spawn_points:
		if _is_spawn_point_valid(spawn_point):
			valid_points.append(spawn_point)

	if valid_points.is_empty():
		return null

	return _pick_weighted_spawn_point(valid_points)


func _is_spawn_point_valid(spawn_point: Marker3D) -> bool:
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var player_distance: float = spawn_point.global_position.distance_to(player.global_position)
		if player_distance < min_player_spawn_distance:
			return false

	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var port_distance: float = spawn_point.global_position.distance_to(port_node.global_position)
		if port_distance < port_avoidance_distance:
			return false

	return true


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
	while _active_creatures.size() < target_creature_count:
		if not _spawn_creature_if_possible():
			break


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
	var density: float = DangerZoneCatalog.get_enemy_density(zone_id)
	var target_count: int = roundi(float(max_creatures) * density * 0.8)
	return clampi(target_count, 1, 8)


func _get_respawn_delay() -> float:
	var zone_id: String = _get_current_danger_zone_id()
	var density: float = DangerZoneCatalog.get_enemy_density(zone_id)
	return clampf(respawn_delay / maxf(0.5, density), 3.0, respawn_delay * 1.5)


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


func _debug_spawn(creature_config: Dictionary, zone_id: String) -> void:
	if not debug_creature_spawns:
		return

	print(
		"MarineCreatureSpawner spawn=%s zone=%s active=%d/%d"
		% [
			String(creature_config.get("name", "Creature")),
			DangerZoneCatalog.get_zone_name(zone_id),
			_active_creatures.size(),
			_get_target_creature_count(),
		]
	)


func _grant_creature_rewards(_world_position: Vector3, creature_id: String, rewards: Dictionary) -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_marine_creature_defeated"):
		game_state.call("record_marine_creature_defeated", creature_id)

	var reward_messages: Array[String] = ["%s vaincu" % MarineCreatureCatalog.get_creature_name(creature_id)]
	var gold_reward: int = maxi(0, int(rewards.get("gold", 0)))
	var wood_reward: int = maxi(0, int(rewards.get("wood", 0)))
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
