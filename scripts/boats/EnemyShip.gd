class_name EnemyShip
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal destroyed(world_position: Vector3, gold_reward: int, wood_reward: int)

@export var enemy_type_id: String = "brigantine"
@export var display_name: String = "Brigantin pirate"
@export var max_health: int = 60
@export var move_speed: float = 7.0
@export var turn_speed: float = 1.15
@export var contact_damage: int = 12
@export var reward_gold: int = 12
@export var reward_wood: int = 8

var health: int
var _destroyed: bool = false


func _ready() -> void:
	health = max_health
	add_to_group("enemy_ships")
	health_changed.emit(health, max_health)


func configure_variant(config: Dictionary) -> void:
	enemy_type_id = String(config.get("id", enemy_type_id))
	display_name = String(config.get("display_name", display_name))
	max_health = int(config.get("max_health", max_health))
	move_speed = float(config.get("move_speed", move_speed))
	turn_speed = float(config.get("turn_speed", turn_speed))
	contact_damage = int(config.get("contact_damage", contact_damage))
	reward_gold = int(config.get("reward_gold", reward_gold))
	reward_wood = int(config.get("reward_wood", reward_wood))

	var visual_scale := float(config.get("visual_scale", 1.0))
	var visuals := get_node_or_null("Visuals") as Node3D
	if visuals != null:
		visuals.scale = Vector3.ONE * visual_scale

	if config.has("hull_color"):
		_set_mesh_color("Visuals/Hull", config["hull_color"])
	if config.has("sail_color"):
		_set_mesh_color("Visuals/Sail", config["sail_color"])

	if is_inside_tree():
		health = clampi(health, 1, max_health)
		health_changed.emit(health, max_health)


func steer_toward(target_position: Vector3, delta: float) -> void:
	if _destroyed:
		return

	var to_target := target_position - global_position
	to_target.y = 0.0

	if to_target.length_squared() < 0.25:
		brake(delta)
		return

	var desired_forward := to_target.normalized()
	var current_forward := -global_transform.basis.z
	var signed_angle := current_forward.signed_angle_to(desired_forward, Vector3.UP)
	var turn_amount := clampf(signed_angle, -turn_speed * delta, turn_speed * delta)

	rotate_y(turn_amount)
	velocity = -global_transform.basis.z * move_speed
	move_and_slide()
	global_position.y = 0.0


func brake(delta: float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
	move_and_slide()
	global_position.y = 0.0


func take_damage(amount: int) -> void:
	if _destroyed:
		return

	health = clampi(health - amount, 0, max_health)
	health_changed.emit(health, max_health)

	if health <= 0:
		_destroy()


func get_contact_damage() -> int:
	return contact_damage


func get_display_name() -> String:
	return display_name


func _destroy() -> void:
	_destroyed = true
	var sink_position := global_position
	var loot_system := get_tree().get_first_node_in_group("loot_system")
	if loot_system != null and loot_system.has_method("drop_from_ship"):
		loot_system.drop_from_ship(sink_position, reward_gold, reward_wood)

	_show_defeat_feedback()
	destroyed.emit(sink_position, reward_gold, reward_wood)
	queue_free()


func _set_mesh_color(node_path: NodePath, color: Color) -> void:
	var mesh_instance := get_node_or_null(node_path) as MeshInstance3D
	if mesh_instance == null:
		return

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material


func _show_defeat_feedback() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return

	var message := "%s vaincu : +%d or, +%d bois" % [display_name, reward_gold, reward_wood]
	if hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, 2.4)
	elif hud.has_method("set_context_message"):
		hud.set_context_message(message)
