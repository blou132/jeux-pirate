class_name MarineCreature
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal defeated(world_position: Vector3, creature_id: String, rewards: Dictionary)

@export var creature_id: String = MarineCreatureCatalog.CREATURE_SHARK
@export var display_name: String = "Requin"
@export var behavior: String = MarineCreatureCatalog.BEHAVIOR_AGGRESSIVE
@export var max_health: int = 28
@export var move_speed: float = 5.0
@export var contact_damage: int = 8
@export var detection_range: float = 22.0
@export var chase_leash_distance: float = 42.0
@export var attack_range: float = 2.2
@export var attack_cooldown: float = 1.7
@export var aggression: float = 0.5
@export var patrol_radius: float = 12.0
@export var flee_distance: float = 18.0
@export var port_safe_radius: float = 45.0
@export var port_expulsion_radius: float = 58.0

var health: int = 0
var spawn_zone_id: String = DangerZoneCatalog.ZONE_SAFE
var _destroyed: bool = false
var _last_damage_source: Node
var _home_position: Vector3 = Vector3.ZERO
var _target: Node3D
var _wander_direction: Vector3 = Vector3.FORWARD
var _wander_timer: float = 0.0
var _attack_cooldown_remaining: float = 0.0
var _safe_zone_cooldown_remaining: float = 0.0
var _spotted_feedback_shown: bool = false


func _ready() -> void:
	add_to_group("marine_creatures")
	_home_position = global_position
	health = max_health
	_apply_catalog_data(creature_id)
	_pick_new_wander_direction()
	_refresh_nameplate()
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	if _destroyed:
		return

	_wander_timer = maxf(0.0, _wander_timer - delta)
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_safe_zone_cooldown_remaining = maxf(0.0, _safe_zone_cooldown_remaining - delta)

	if _is_position_inside_port_safe_zone(global_position):
		_target = null
		_safe_zone_cooldown_remaining = 2.0
		_move_away_from_closest_port(delta)
		return

	if behavior == MarineCreatureCatalog.BEHAVIOR_PASSIVE:
		_process_passive_behavior(delta)
	else:
		_process_aggressive_behavior(delta)


func configure_creature(config: Dictionary, zone_id: String) -> void:
	spawn_zone_id = DangerZoneCatalog.normalize_zone_id(zone_id)
	creature_id = String(config.get("id", creature_id))
	_apply_catalog_data(creature_id)
	health = max_health
	_home_position = global_position
	_pick_new_wander_direction()
	health_changed.emit(health, max_health)


func take_damage(amount: int, source: Node = null) -> void:
	if _destroyed:
		return

	_last_damage_source = source
	health = clampi(health - amount, 0, max_health)
	_refresh_nameplate()
	health_changed.emit(health, max_health)

	if health <= 0:
		_defeat()


func is_destroyed() -> bool:
	return _destroyed


func is_alive() -> bool:
	return not _destroyed and health > 0


func can_be_targeted() -> bool:
	return is_alive()


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_display_name() -> String:
	return display_name


func get_creature_id() -> String:
	return creature_id


func get_aim_position() -> Vector3:
	var aim_point: Node3D = get_node_or_null("AimPoint") as Node3D
	if aim_point != null:
		return aim_point.global_position

	return global_position


func get_rewards() -> Dictionary:
	var creature: Dictionary = MarineCreatureCatalog.get_creature(creature_id)
	var reward_multiplier: float = DangerZoneCatalog.get_reward_multiplier(spawn_zone_id)
	var gold_reward: int = roundi(float(maxi(0, int(creature.get("reward_gold", 0)))) * reward_multiplier)
	var wood_reward: int = roundi(float(maxi(0, int(creature.get("reward_wood", 0)))) * reward_multiplier)
	var renown_reward: int = roundi(float(maxi(0, int(creature.get("renown_reward", 0)))) * reward_multiplier)
	return {
		"gold": gold_reward,
		"wood": wood_reward,
		"renown": renown_reward,
		"map_fragments": maxi(0, int(creature.get("map_fragments_reward", 0))),
		"rare_resource_id": String(creature.get("rare_resource_id", "")),
		"rare_resource_chance": clampf(float(creature.get("rare_resource_chance", 0.0)), 0.0, 1.0),
		"rare_resource_amount": maxi(0, int(creature.get("rare_resource_amount", 0))),
		"reward_multiplier": reward_multiplier,
	}


func _apply_catalog_data(target_creature_id: String) -> void:
	var creature: Dictionary = MarineCreatureCatalog.get_creature(target_creature_id)
	creature_id = String(creature.get("id", target_creature_id))
	display_name = String(creature.get("name", display_name))
	behavior = String(creature.get("behavior", behavior))
	max_health = maxi(1, int(creature.get("max_health", max_health)))
	move_speed = maxf(0.1, float(creature.get("move_speed", move_speed)))
	contact_damage = maxi(0, int(creature.get("damage", contact_damage)))
	detection_range = maxf(0.0, float(creature.get("detection_range", detection_range)))
	chase_leash_distance = maxf(detection_range, float(creature.get("chase_leash_distance", chase_leash_distance)))
	attack_range = maxf(0.0, float(creature.get("attack_range", attack_range)))
	attack_cooldown = maxf(0.2, float(creature.get("attack_cooldown", attack_cooldown)))
	aggression = clampf(float(creature.get("aggression", aggression)), 0.0, 1.0)
	_apply_visuals(creature)
	_refresh_nameplate()


func _apply_visuals(creature: Dictionary) -> void:
	var visuals: Node3D = get_node_or_null("Visuals") as Node3D
	if visuals != null:
		var visual_scale: Vector3 = creature.get("visual_scale", Vector3.ONE)
		visuals.scale = visual_scale

	var visual_color: Color = creature.get("visual_color", Color(0.2, 0.45, 0.55, 1.0))
	_set_mesh_color("Visuals/Body", visual_color)

	var fin_color: Color = visual_color.darkened(0.25)
	_set_mesh_color("Visuals/Fin", fin_color)
	_set_mesh_color("Visuals/Tail", fin_color)


func _set_mesh_color(node_path: NodePath, color: Color) -> void:
	var mesh_instance: MeshInstance3D = get_node_or_null(node_path) as MeshInstance3D
	if mesh_instance == null:
		return

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material


func _refresh_nameplate() -> void:
	var nameplate: Label3D = get_node_or_null("Nameplate") as Label3D
	if nameplate != null:
		nameplate.text = "%s - %d PV" % [display_name, health]


func _defeat() -> void:
	if _destroyed:
		return

	_destroyed = true
	velocity = Vector3.ZERO
	defeated.emit(global_position, creature_id, get_rewards())
	queue_free()


func _show_spotted_feedback() -> void:
	if _spotted_feedback_shown:
		return
	if aggression < 0.5:
		return

	_spotted_feedback_shown = true
	var message: String = "%s repere" % display_name
	if creature_id == MarineCreatureCatalog.CREATURE_JUVENILE_KRAKEN:
		message = "Kraken juvenile dans les eaux hostiles"

	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.call("show_temporary_context_message", message, 1.4)


func _process_passive_behavior(delta: float) -> void:
	var threat: Node3D = _get_closest_target(detection_range)
	if threat != null:
		var flee_direction: Vector3 = global_position - threat.global_position
		flee_direction.y = 0.0
		if flee_direction.length_squared() > 0.01:
			_move_along_direction(flee_direction.normalized(), delta, 1.25)
			return

	_patrol(delta)


func _process_aggressive_behavior(delta: float) -> void:
	if _safe_zone_cooldown_remaining > 0.0:
		_patrol(delta)
		return

	if not _is_valid_target(_target, chase_leash_distance):
		_target = _get_closest_target(detection_range)
		if _target != null:
			_show_spotted_feedback()

	if _target == null:
		_patrol(delta)
		return

	var offset: Vector3 = _target.global_position - global_position
	offset.y = 0.0
	var distance: float = offset.length()
	if distance > chase_leash_distance:
		_target = null
		_patrol(delta)
		return

	if distance <= attack_range:
		_attack_target(_target)
		_slow_down(delta)
		return

	if offset.length_squared() > 0.01:
		_move_along_direction(offset.normalized(), delta, 1.0 + (aggression * 0.18))
	else:
		_slow_down(delta)


func _patrol(delta: float) -> void:
	if _wander_timer <= 0.0:
		_pick_new_wander_direction()

	var offset_from_home: Vector3 = global_position - _home_position
	offset_from_home.y = 0.0
	var desired_direction: Vector3 = _wander_direction
	if offset_from_home.length() > patrol_radius:
		desired_direction = (_home_position - global_position).normalized()
		desired_direction.y = 0.0

	if desired_direction.length_squared() < 0.01:
		_slow_down(delta)
		return

	_move_along_direction(desired_direction.normalized(), delta, 0.55)


func _attack_target(target: Node3D) -> void:
	if _attack_cooldown_remaining > 0.0:
		return
	if contact_damage <= 0:
		return
	if target == null or not is_instance_valid(target):
		return
	if _is_position_inside_port_safe_zone(target.global_position):
		_target = null
		_safe_zone_cooldown_remaining = 2.0
		return

	if target.has_method("take_damage"):
		target.call("take_damage", contact_damage)
		_attack_cooldown_remaining = attack_cooldown


func _move_along_direction(direction: Vector3, delta: float, speed_scale: float) -> void:
	if direction.length_squared() < 0.01:
		_slow_down(delta)
		return

	direction.y = 0.0
	direction = direction.normalized()
	velocity = direction * move_speed * maxf(0.0, speed_scale)
	move_and_slide()
	global_position.y = 0.0
	_face_direction(direction, delta)


func _slow_down(delta: float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
	move_and_slide()
	global_position.y = 0.0


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.01:
		return

	var current_forward: Vector3 = -global_transform.basis.z
	current_forward.y = 0.0
	if current_forward.length_squared() < 0.01:
		look_at(global_position + direction, Vector3.UP)
		return

	current_forward = current_forward.normalized()
	var signed_angle: float = current_forward.signed_angle_to(direction.normalized(), Vector3.UP)
	var turn_amount: float = clampf(signed_angle, -2.4 * delta, 2.4 * delta)
	rotate_y(turn_amount)


func _pick_new_wander_direction() -> void:
	var angle: float = randf_range(0.0, TAU)
	_wander_direction = Vector3(cos(angle), 0.0, sin(angle)).normalized()
	_wander_timer = randf_range(2.2, 4.8)


func _get_closest_target(search_range: float) -> Node3D:
	var closest_target: Node3D
	var closest_distance_squared: float = search_range * search_range

	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if _is_valid_target(player, search_range):
		closest_target = player
		closest_distance_squared = global_position.distance_squared_to(player.global_position)

	for ally in get_tree().get_nodes_in_group("ally_ships"):
		if not ally is Node3D:
			continue

		var ally_node: Node3D = ally as Node3D
		if not _is_valid_target(ally_node, search_range):
			continue

		var distance_squared: float = global_position.distance_squared_to(ally_node.global_position)
		if distance_squared <= closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_target = ally_node

	return closest_target


func _is_valid_target(target: Node, search_range: float) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	if not target is Node3D:
		return false
	if target.has_method("can_be_targeted") and not bool(target.call("can_be_targeted")):
		return false
	if target.has_method("is_alive") and not bool(target.call("is_alive")):
		return false
	if target.has_method("is_destroyed") and bool(target.call("is_destroyed")):
		return false

	var target_node: Node3D = target as Node3D
	if _is_position_inside_port_safe_zone(target_node.global_position):
		return false

	return global_position.distance_squared_to(target_node.global_position) <= search_range * search_range


func _is_position_inside_port_safe_zone(position: Vector3) -> bool:
	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var offset: Vector3 = position - port_node.global_position
		offset.y = 0.0
		if offset.length_squared() <= port_safe_radius * port_safe_radius:
			return true

	return false


func _move_away_from_closest_port(delta: float) -> void:
	var closest_port: Node3D
	var closest_distance_squared: float = INF
	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var distance_squared: float = global_position.distance_squared_to(port_node.global_position)
		if distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_port = port_node

	if closest_port == null:
		_patrol(delta)
		return

	var escape_direction: Vector3 = global_position - closest_port.global_position
	escape_direction.y = 0.0
	if escape_direction.length_squared() < 0.01:
		escape_direction = Vector3.FORWARD

	_move_along_direction(escape_direction.normalized(), delta, 1.1)
	var offset_from_port: Vector3 = global_position - closest_port.global_position
	offset_from_port.y = 0.0
	if offset_from_port.length() < port_expulsion_radius:
		global_position = closest_port.global_position + (offset_from_port.normalized() * port_expulsion_radius)
		global_position.y = 0.0
