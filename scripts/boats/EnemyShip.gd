class_name EnemyShip
extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal destroyed(world_position: Vector3, gold_reward: int, wood_reward: int)

@export var enemy_type_id: String = "brigantine"
@export var display_name: String = "Brigantin pirate"
@export var max_health: int = 60
@export var move_speed: float = 7.0
@export var chase_speed_multiplier: float = 1.15
@export var turn_speed: float = 1.15
@export var turn_acceleration: float = 2.8
@export var turn_deceleration: float = 3.2
@export var contact_damage: int = 12
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 2.2
@export var detection_range: float = 48.0
@export var chase_leash_distance: float = 75.0
@export var reward_gold: int = 12
@export var reward_wood: int = 8
@export var cannon_point_base_half_width: float = 1.35
@export var cannon_point_height: float = 0.65
@export var cannon_point_forward_offset: float = -0.25
# Temporary v0.3.7 helper to inspect enemy broadside cannon points during tests.
@export var debug_show_aim_points: bool = false

var health: int
var angular_velocity: float = 0.0
var _destroyed: bool = false
var _last_damage_source: Node


func _ready() -> void:
	health = max_health
	add_to_group("enemy_ships")
	_refresh_debug_markers()
	_refresh_nameplate()
	health_changed.emit(health, max_health)


func configure_variant(config: Dictionary) -> void:
	enemy_type_id = String(config.get("id", enemy_type_id))
	display_name = String(config.get("display_name", display_name))
	max_health = int(config.get("max_health", max_health))
	move_speed = float(config.get("move_speed", move_speed))
	chase_speed_multiplier = float(config.get("chase_speed_multiplier", chase_speed_multiplier))
	turn_speed = float(config.get("turn_speed", turn_speed))
	turn_acceleration = float(config.get("turn_acceleration", turn_acceleration))
	turn_deceleration = float(config.get("turn_deceleration", turn_deceleration))
	contact_damage = int(config.get("contact_damage", contact_damage))
	attack_range = float(config.get("attack_range", attack_range))
	attack_cooldown = float(config.get("attack_cooldown", attack_cooldown))
	detection_range = float(config.get("detection_range", detection_range))
	chase_leash_distance = float(config.get("chase_leash_distance", chase_leash_distance))
	reward_gold = int(config.get("reward_gold", reward_gold))
	reward_wood = int(config.get("reward_wood", reward_wood))

	var visual_scale := float(config.get("visual_scale", 1.0))
	var visuals := get_node_or_null("Visuals") as Node3D
	if visuals != null:
		visuals.scale = Vector3.ONE * visual_scale

	if config.has("hull_scale"):
		_set_node_scale("Visuals/Hull", config["hull_scale"])
	if config.has("deck_scale"):
		_set_node_scale("Visuals/Deck", config["deck_scale"])
	if config.has("mast_scale"):
		_set_node_scale("Visuals/Mast", config["mast_scale"])
	if config.has("sail_scale"):
		_set_node_scale("Visuals/Sail", config["sail_scale"])

	if config.has("hull_color"):
		_set_mesh_color("Visuals/Hull", config["hull_color"])
	if config.has("sail_color"):
		_set_mesh_color("Visuals/Sail", config["sail_color"])
	if config.has("nameplate_height"):
		_set_nameplate_height(float(config["nameplate_height"]))

	_apply_visual_style(String(config.get("visual_style", "brigantine")))
	_refresh_cannon_points(visual_scale)
	_refresh_debug_markers()
	_refresh_nameplate()

	if is_inside_tree():
		health = clampi(health, 1, max_health)
		_refresh_nameplate()
		health_changed.emit(health, max_health)


func steer_toward(target_position: Vector3, delta: float) -> void:
	if _destroyed:
		return

	var to_target := target_position - global_position
	to_target.y = 0.0

	if to_target.length_squared() < 0.25:
		brake(delta)
		return

	steer_along_direction(to_target.normalized(), delta)


func steer_along_direction(desired_forward: Vector3, delta: float) -> void:
	steer_along_direction_with_speed(desired_forward, delta, 1.0)


func steer_along_direction_with_speed(desired_forward: Vector3, delta: float, speed_scale: float) -> void:
	if _destroyed:
		return
	if desired_forward.length_squared() < 0.01:
		brake(delta)
		return

	desired_forward.y = 0.0
	desired_forward = desired_forward.normalized()
	var current_forward: Vector3 = -global_transform.basis.z
	current_forward.y = 0.0
	if current_forward.length_squared() < 0.01:
		brake(delta)
		return

	current_forward = current_forward.normalized()
	var signed_angle: float = current_forward.signed_angle_to(desired_forward, Vector3.UP)
	var max_turn_rate: float = maxf(0.0, turn_speed)
	var target_angular_velocity: float = clampf(
		signed_angle * turn_acceleration,
		-max_turn_rate,
		max_turn_rate
	)
	angular_velocity = move_toward(
		angular_velocity,
		target_angular_velocity,
		turn_acceleration * delta
	)

	if absf(signed_angle) < 0.02:
		angular_velocity = move_toward(angular_velocity, 0.0, turn_deceleration * delta)

	var turn_amount: float = angular_velocity * delta
	if absf(turn_amount) > absf(signed_angle):
		turn_amount = signed_angle
		angular_velocity = 0.0

	var clamped_speed_scale: float = clampf(speed_scale, 0.0, maxf(1.0, chase_speed_multiplier))

	rotate_y(turn_amount)
	velocity = -global_transform.basis.z * move_speed * clamped_speed_scale
	move_and_slide()
	global_position.y = 0.0


func brake(delta: float) -> void:
	angular_velocity = move_toward(angular_velocity, 0.0, turn_deceleration * delta)
	velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
	move_and_slide()
	global_position.y = 0.0


func take_damage(amount: int, source: Node = null) -> void:
	if _destroyed:
		return

	_last_damage_source = source
	health = clampi(health - amount, 0, max_health)
	_refresh_nameplate()
	health_changed.emit(health, max_health)

	if health <= 0:
		_destroy()


func get_contact_damage() -> int:
	return contact_damage


func get_attack_range() -> float:
	return attack_range


func get_attack_cooldown() -> float:
	return attack_cooldown


func get_detection_range() -> float:
	return detection_range


func get_chase_leash_distance() -> float:
	return chase_leash_distance


func get_chase_speed_multiplier() -> float:
	return chase_speed_multiplier


func get_turn_load() -> float:
	if turn_speed <= 0.0:
		return 0.0

	return clampf(absf(angular_velocity) / turn_speed, 0.0, 1.0)


func get_display_name() -> String:
	return display_name


func get_enemy_type_id() -> String:
	return enemy_type_id


func is_destroyed() -> bool:
	return _destroyed


func get_aim_position() -> Vector3:
	var aim_point := get_node_or_null("AimPoint") as Node3D
	if aim_point != null:
		return aim_point.global_position

	return global_position


func get_broadside_cannon_position(fire_direction: Vector3, fallback_offset: float, fallback_height: float) -> Vector3:
	var cannon_point := _get_broadside_cannon_point(fire_direction)
	if cannon_point != null:
		return cannon_point.global_position

	var side_direction: Vector3 = fire_direction.normalized()
	side_direction.y = 0.0
	return global_position + (side_direction * fallback_offset) + Vector3(0.0, fallback_height, 0.0)


func get_starboard_axis() -> Vector3:
	var left_point := get_node_or_null("LeftCannonPoint") as Node3D
	var right_point := get_node_or_null("RightCannonPoint") as Node3D
	if left_point != null and right_point != null:
		var marker_axis: Vector3 = right_point.global_position - left_point.global_position
		marker_axis.y = 0.0
		if marker_axis.length_squared() > 0.01:
			return marker_axis.normalized()

	var fallback_axis: Vector3 = global_transform.basis.x
	fallback_axis.y = 0.0
	return fallback_axis.normalized()


func get_port_axis() -> Vector3:
	return -get_starboard_axis()


func _destroy() -> void:
	_destroyed = true
	angular_velocity = 0.0
	velocity = Vector3.ZERO
	var sink_position := global_position
	var final_gold_reward: int = _get_adjusted_reward_gold()
	var loot_system := get_tree().get_first_node_in_group("loot_system")
	if loot_system != null and loot_system.has_method("drop_from_ship"):
		loot_system.drop_from_ship(sink_position, final_gold_reward, reward_wood)

	_show_defeat_feedback(final_gold_reward, reward_wood)
	destroyed.emit(sink_position, final_gold_reward, reward_wood)
	queue_free()


func _set_mesh_color(node_path: NodePath, color: Color) -> void:
	var mesh_instance := get_node_or_null(node_path) as MeshInstance3D
	if mesh_instance == null:
		return

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material


func _set_node_scale(node_path: NodePath, scale_value: Vector3) -> void:
	var node := get_node_or_null(node_path) as Node3D
	if node != null:
		node.scale = scale_value


func _apply_visual_style(visual_style: String) -> void:
	var details := _get_variant_details()
	if details == null:
		return

	for child in details.get_children():
		child.queue_free()

	match visual_style:
		"small":
			_add_box_detail(details, "LightSailStripe", Vector3(0, 1.9, -0.24), Vector3(1.35, 0.08, 0.1), Color(0.95, 0.74, 0.26, 1.0))
			_add_box_detail(details, "NarrowStern", Vector3(0, 0.55, 1.75), Vector3(1.1, 0.25, 0.45), Color(0.62, 0.22, 0.12, 1.0))
		"brigantine":
			_add_box_detail(details, "SecondSail", Vector3(0, 1.35, 0.75), Vector3(1.15, 0.85, 0.08), Color(0.18, 0.16, 0.13, 1.0))
			_add_box_detail(details, "LongDeck", Vector3(0, 0.62, 0.35), Vector3(1.55, 0.16, 1.0), Color(0.38, 0.22, 0.1, 1.0))
		"heavy":
			_add_box_detail(details, "PortArmor", Vector3(-1.2, 0.62, 0), Vector3(0.28, 0.5, 3.8), Color(0.12, 0.13, 0.16, 1.0))
			_add_box_detail(details, "StarboardArmor", Vector3(1.2, 0.62, 0), Vector3(0.28, 0.5, 3.8), Color(0.12, 0.13, 0.16, 1.0))
			_add_box_detail(details, "HeavyCabin", Vector3(0, 0.9, 1.2), Vector3(1.25, 0.65, 0.9), Color(0.18, 0.18, 0.2, 1.0))
			_add_box_detail(details, "TallSailTop", Vector3(0, 2.05, -0.18), Vector3(1.55, 0.35, 0.1), Color(0.34, 0.33, 0.3, 1.0))


func _get_variant_details() -> Node3D:
	var visuals := get_node_or_null("Visuals") as Node3D
	if visuals == null:
		return null

	var details := visuals.get_node_or_null("VariantDetails") as Node3D
	if details == null:
		details = Node3D.new()
		details.name = "VariantDetails"
		visuals.add_child(details)

	return details


func _add_box_detail(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _make_material(color)
	parent.add_child(mesh_instance)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func _get_adjusted_reward_gold() -> int:
	var adjusted_reward: int = reward_gold
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("get_player_ship_combat_gold_multiplier"):
		var multiplier: float = float(game_state.call("get_player_ship_combat_gold_multiplier"))
		adjusted_reward = roundi(float(reward_gold) * multiplier)

	return maxi(0, adjusted_reward)


func _show_defeat_feedback(gold_amount: int, wood_amount: int) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return

	var message := "%s vaincu : +%d or, +%d bois" % [display_name, gold_amount, wood_amount]
	if _last_damage_source != null and is_instance_valid(_last_damage_source) and _last_damage_source.is_in_group("ally_ships"):
		message = "Allié a coulé %s : +%d or, +%d bois" % [display_name, gold_amount, wood_amount]

	if hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, 2.4)
	elif hud.has_method("set_context_message"):
		hud.set_context_message(message)


func _refresh_nameplate() -> void:
	var nameplate := get_node_or_null("Nameplate") as Label3D
	if nameplate != null:
		nameplate.text = "%s - %d PV" % [display_name, health]


func _set_nameplate_height(height: float) -> void:
	var nameplate := get_node_or_null("Nameplate") as Label3D
	if nameplate != null:
		nameplate.position.y = height


func _refresh_cannon_points(visual_scale: float) -> void:
	var hull_scale := _get_node_scale("Visuals/Hull")
	var half_width := cannon_point_base_half_width * visual_scale * hull_scale.x

	var left_point := get_node_or_null("LeftCannonPoint") as Node3D
	if left_point != null:
		left_point.position = Vector3(-half_width, cannon_point_height, cannon_point_forward_offset)

	var right_point := get_node_or_null("RightCannonPoint") as Node3D
	if right_point != null:
		right_point.position = Vector3(half_width, cannon_point_height, cannon_point_forward_offset)


func _get_node_scale(node_path: NodePath) -> Vector3:
	var node := get_node_or_null(node_path) as Node3D
	if node != null:
		return node.scale

	return Vector3.ONE


func _get_broadside_cannon_point(fire_direction: Vector3) -> Node3D:
	if fire_direction.length_squared() < 0.01:
		return null

	var right_direction: Vector3 = get_starboard_axis()
	if fire_direction.normalized().dot(right_direction) >= 0.0:
		return get_node_or_null("RightCannonPoint") as Node3D

	return get_node_or_null("LeftCannonPoint") as Node3D


func _refresh_debug_markers() -> void:
	var marker_paths: Array[NodePath] = [
		NodePath("AimPoint/DebugMarker"),
		NodePath("LeftCannonPoint/DebugMarker"),
		NodePath("RightCannonPoint/DebugMarker"),
	]

	for marker_path in marker_paths:
		var marker := get_node_or_null(marker_path) as Node3D
		if marker != null:
			marker.visible = debug_show_aim_points
