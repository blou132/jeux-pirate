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

var health: int = 0
var spawn_zone_id: String = DangerZoneCatalog.ZONE_SAFE
var _destroyed: bool = false
var _last_damage_source: Node


func _ready() -> void:
	add_to_group("marine_creatures")
	health = max_health
	_apply_catalog_data(creature_id)
	_refresh_nameplate()
	health_changed.emit(health, max_health)


func configure_creature(config: Dictionary, zone_id: String) -> void:
	spawn_zone_id = DangerZoneCatalog.normalize_zone_id(zone_id)
	creature_id = String(config.get("id", creature_id))
	_apply_catalog_data(creature_id)
	health = max_health
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
	return {
		"gold": maxi(0, int(creature.get("reward_gold", 0))),
		"wood": maxi(0, int(creature.get("reward_wood", 0))),
		"renown": maxi(0, int(creature.get("renown_reward", 0))),
		"map_fragments": maxi(0, int(creature.get("map_fragments_reward", 0))),
		"rare_resource_id": String(creature.get("rare_resource_id", "")),
		"rare_resource_chance": clampf(float(creature.get("rare_resource_chance", 0.0)), 0.0, 1.0),
		"rare_resource_amount": maxi(0, int(creature.get("rare_resource_amount", 0))),
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
