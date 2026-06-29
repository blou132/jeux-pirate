extends Node

@export var enemy_cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/EnemyCannonBall.tscn")
@export var detection_range: float = 48.0
@export var stop_distance: float = 7.0
@export var projectile_speed: float = 13.0
@export var broadside_fire_alignment_degrees: float = 25.0
@export var broadside_line_tolerance: float = 1.2
@export var broadside_muzzle_offset: float = 2.2
@export var broadside_muzzle_height: float = 0.75
@export var broadside_preferred_distance_ratio: float = 0.78
@export var broadside_distance_margin: float = 1.5
@export var broadside_radial_weight: float = 0.55
@export var broadside_maneuver_speed_scale: float = 0.58
@export var broadside_retreat_speed_scale: float = 0.55
@export var broadside_turn_slowdown: float = 0.2
@export var broadside_min_maneuver_speed_scale: float = 0.35
@export var broadside_line_correction_weight: float = 0.7
@export var broadside_side_lock_duration: float = 1.5
@export var port_safe_radius: float = 45.0
@export var port_expulsion_radius: float = 60.0
@export var island_safe_radius: float = 24.0
@export var island_expulsion_radius: float = 42.0
@export var safe_zone_reengage_cooldown: float = 3.0
@export var safe_zone_escape_speed_scale: float = 1.0
# Temporary v0.3.5 console helper to verify enemy broadside selection during tests.
@export var debug_broadside_fire: bool = false
@export var debug_broadside_fire_interval: float = 1.5
@export var debug_show_broadside_lines: bool = false
@export var debug_broadside_line_length: float = 28.0
@export var debug_show_enemy_detection: bool = false
@export var debug_detection_segments: int = 48
@export var debug_detection_height: float = 0.08

const BROADSIDE_SIDE_NONE := 0
const BROADSIDE_SIDE_PORT := -1
const BROADSIDE_SIDE_STARBOARD := 1

@onready var ship: EnemyShip = get_parent() as EnemyShip

var _player: Node3D
var _attack_cooldown_remaining: float = 0.0
var _debug_message_cooldown_remaining: float = 0.0
var _locked_broadside_side: int = BROADSIDE_SIDE_NONE
var _side_lock_remaining: float = 0.0
var _safe_zone_cooldown_remaining: float = 0.0
var _safe_zone_escape_position: Vector3 = Vector3.ZERO
var _has_safe_zone_escape_position: bool = false
var _debug_line_instance: MeshInstance3D
var _debug_detection_instance: MeshInstance3D
var _debug_line_material: StandardMaterial3D


func _physics_process(delta: float) -> void:
	if ship == null:
		return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_debug_message_cooldown_remaining = maxf(0.0, _debug_message_cooldown_remaining - delta)
	_side_lock_remaining = maxf(0.0, _side_lock_remaining - delta)
	_safe_zone_cooldown_remaining = maxf(0.0, _safe_zone_cooldown_remaining - delta)
	_update_detection_debug()

	if _is_ship_inside_safe_zone():
		_begin_safe_zone_escape()

	if _safe_zone_cooldown_remaining > 0.0:
		_clear_broadside_debug_lines()
		_clear_broadside_side_lock()
		_player = null
		_move_to_safe_zone_escape(delta)
		return

	_player = _get_or_find_hostile_target()

	if _player == null:
		_clear_broadside_debug_lines()
		_clear_broadside_side_lock()
		ship.brake(delta)
		return

	var player_aim_position: Vector3 = _get_player_aim_position()
	var offset: Vector3 = player_aim_position - ship.global_position
	offset.y = 0.0
	var distance_squared: float = offset.length_squared()
	var attack_range: float = _get_attack_range()
	var active_chase_leash := _get_chase_leash_distance()
	var distance_to_player: float = sqrt(distance_squared)

	if distance_squared > active_chase_leash * active_chase_leash:
		_clear_broadside_debug_lines()
		_clear_broadside_side_lock()
		_begin_disengage_from_position(player_aim_position)
		return

	_update_broadside_debug_lines(offset)

	if distance_squared <= attack_range * attack_range:
		var fire_direction: Vector3 = _get_ready_broadside_fire_direction(offset)
		if fire_direction == Vector3.ZERO:
			_maneuver_for_broadside(offset, distance_to_player, attack_range, delta)
			return

		ship.brake(delta)
		_try_attack_player(fire_direction)
		return

	_clear_broadside_side_lock()
	ship.steer_toward(player_aim_position, delta)


func _try_attack_player(fire_direction: Vector3) -> void:
	if _attack_cooldown_remaining > 0.0 or _player == null:
		return

	var confirmed_fire_direction: Vector3 = _get_confirmed_broadside_fire_direction(fire_direction)
	if confirmed_fire_direction == Vector3.ZERO:
		return

	var damage := 0
	if ship.has_method("get_contact_damage"):
		damage = ship.get_contact_damage()

	if damage <= 0:
		return

	_show_broadside_debug(confirmed_fire_direction)
	_fire_projectile(damage, confirmed_fire_direction)
	_attack_cooldown_remaining = _get_attack_cooldown()


func _get_attack_range() -> float:
	if ship.has_method("get_attack_range"):
		return ship.get_attack_range()

	return stop_distance


func _get_attack_cooldown() -> float:
	if ship.has_method("get_attack_cooldown"):
		return ship.get_attack_cooldown()

	return 2.0


func _get_detection_range() -> float:
	if ship.has_method("get_detection_range"):
		return float(ship.get_detection_range())

	return detection_range


func _get_chase_leash_distance() -> float:
	if ship.has_method("get_chase_leash_distance"):
		return maxf(float(ship.get_chase_leash_distance()), _get_detection_range())

	return _get_detection_range()


func _get_or_find_hostile_target() -> Node3D:
	if _is_valid_chase_target(_player):
		return _player

	return _get_closest_hostile_target()


func _get_closest_hostile_target() -> Node3D:
	var closest_target: Node3D
	var active_detection_range: float = _get_detection_range()
	var closest_distance_squared: float = active_detection_range * active_detection_range

	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if _is_valid_hostile_target(player):
		closest_target = player
		closest_distance_squared = ship.global_position.distance_squared_to(player.global_position)

	for ally in get_tree().get_nodes_in_group("ally_ships"):
		if not ally is Node3D:
			continue
		if not _is_valid_hostile_target(ally):
			continue

		var ally_node: Node3D = ally as Node3D
		var distance_squared: float = ship.global_position.distance_squared_to(ally_node.global_position)
		if distance_squared <= closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_target = ally_node

	return closest_target


func _is_valid_chase_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	if not _is_target_combat_ready(target):
		return false
	if not target is Node3D:
		return false

	var target_node: Node3D = target as Node3D
	if _is_position_inside_safe_zone(target_node.global_position):
		return false

	var chase_leash: float = _get_chase_leash_distance()
	return ship.global_position.distance_squared_to(target_node.global_position) <= chase_leash * chase_leash


func _is_valid_hostile_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	if not _is_target_combat_ready(target):
		return false
	if not target is Node3D:
		return false

	var target_node: Node3D = target as Node3D
	if _is_position_inside_safe_zone(target_node.global_position):
		return false

	var active_detection_range: float = _get_detection_range()
	return ship.global_position.distance_squared_to(target_node.global_position) <= active_detection_range * active_detection_range


func _is_target_combat_ready(target: Node) -> bool:
	if target.has_method("can_be_targeted") and not bool(target.call("can_be_targeted")):
		return false
	if target.has_method("is_alive") and not bool(target.call("is_alive")):
		return false
	if target.has_method("is_destroyed") and bool(target.call("is_destroyed")):
		return false

	return true


func _is_ship_inside_safe_zone() -> bool:
	if ship == null:
		return false

	return _is_position_inside_safe_zone(ship.global_position)


func _is_position_inside_safe_zone(position: Vector3) -> bool:
	return _is_position_inside_port_safe_zone(position)


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


func _begin_safe_zone_escape() -> void:
	var escape_position := _get_closest_safe_zone_escape_position()
	if not _is_valid_escape_position(escape_position):
		return

	_safe_zone_escape_position = escape_position
	_safe_zone_escape_position.y = 0.0
	_has_safe_zone_escape_position = true
	_safe_zone_cooldown_remaining = safe_zone_reengage_cooldown
	_player = null


func _begin_disengage_from_position(threat_position: Vector3) -> void:
	var escape_direction := ship.global_position - threat_position
	escape_direction.y = 0.0
	if escape_direction.length_squared() < 0.01:
		escape_direction = -ship.global_transform.basis.z
		escape_direction.y = 0.0
	if escape_direction.length_squared() < 0.01:
		escape_direction = Vector3.FORWARD

	var escape_distance := maxf(_get_detection_range(), 24.0)
	_safe_zone_escape_position = ship.global_position + (escape_direction.normalized() * escape_distance)
	_safe_zone_escape_position.y = 0.0
	_has_safe_zone_escape_position = true
	_safe_zone_cooldown_remaining = safe_zone_reengage_cooldown
	_player = null


func _get_closest_safe_zone_escape_position() -> Vector3:
	var closest_center: Vector3 = Vector3.ZERO
	var closest_expulsion_radius: float = port_expulsion_radius
	var closest_distance_squared: float = INF
	var found_anchor: bool = false

	for port in get_tree().get_nodes_in_group("ports"):
		if not port is Node3D:
			continue

		var port_node: Node3D = port as Node3D
		var distance_squared: float = ship.global_position.distance_squared_to(port_node.global_position)
		if distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_center = port_node.global_position
			closest_expulsion_radius = port_expulsion_radius
			found_anchor = true

	if not found_anchor:
		return Vector3(INF, INF, INF)

	var escape_direction := ship.global_position - closest_center
	escape_direction.y = 0.0
	if escape_direction.length_squared() < 0.01:
		escape_direction = -ship.global_transform.basis.z
		escape_direction.y = 0.0
	if escape_direction.length_squared() < 0.01:
		escape_direction = Vector3.FORWARD

	return closest_center + (escape_direction.normalized() * closest_expulsion_radius)


func _is_valid_escape_position(position: Vector3) -> bool:
	return position.x != INF and position.y != INF and position.z != INF


func _move_to_safe_zone_escape(delta: float) -> void:
	if not _has_safe_zone_escape_position:
		ship.brake(delta)
		return

	var offset := _safe_zone_escape_position - ship.global_position
	offset.y = 0.0
	if offset.length_squared() <= 1.0:
		ship.brake(delta)
		return

	if ship.has_method("steer_along_direction_with_speed"):
		ship.steer_along_direction_with_speed(offset.normalized(), delta, safe_zone_escape_speed_scale)
	elif ship.has_method("steer_along_direction"):
		ship.steer_along_direction(offset.normalized(), delta)
	else:
		ship.steer_toward(_safe_zone_escape_position, delta)


func _get_confirmed_broadside_fire_direction(candidate_direction: Vector3) -> Vector3:
	if not is_instance_valid(_player):
		return Vector3.ZERO
	if candidate_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var offset_to_player: Vector3 = _get_player_aim_position() - ship.global_position
	offset_to_player.y = 0.0
	var aligned_direction: Vector3 = _get_broadside_fire_direction(offset_to_player)
	if aligned_direction == Vector3.ZERO:
		return Vector3.ZERO

	if aligned_direction.normalized().dot(candidate_direction.normalized()) <= 0.0:
		return Vector3.ZERO
	if not _is_broadside_aim_line_valid(aligned_direction):
		return Vector3.ZERO

	return aligned_direction


func _get_ready_broadside_fire_direction(offset_to_player: Vector3) -> Vector3:
	var fire_direction: Vector3 = _get_broadside_fire_direction(offset_to_player)
	if fire_direction == Vector3.ZERO:
		return Vector3.ZERO
	if not _is_broadside_aim_line_valid(fire_direction):
		return Vector3.ZERO

	return fire_direction


func _is_broadside_aim_line_valid(fire_direction: Vector3) -> bool:
	if fire_direction.length_squared() < 0.01:
		return false

	var line_origin: Vector3 = _get_broadside_muzzle_position(fire_direction)
	var line_direction: Vector3 = fire_direction.normalized()
	line_direction.y = 0.0
	if line_direction.length_squared() < 0.01:
		return false

	var target_position: Vector3 = _get_player_aim_position()
	var to_target: Vector3 = target_position - line_origin
	var parallel_distance: float = to_target.dot(line_direction)
	if parallel_distance <= 0.0:
		return false

	var closest_point: Vector3 = line_origin + (line_direction * parallel_distance)
	var perpendicular_distance: float = target_position.distance_to(closest_point)
	return perpendicular_distance <= broadside_line_tolerance


func _get_broadside_fire_direction(offset_to_player: Vector3) -> Vector3:
	if offset_to_player.length_squared() < 0.01:
		return Vector3.ZERO

	var to_player: Vector3 = offset_to_player.normalized()
	var preferred_side: int = _get_preferred_broadside_side(offset_to_player, true)
	var fire_direction: Vector3 = _get_broadside_axis_for_side(preferred_side)
	if fire_direction == Vector3.ZERO:
		return Vector3.ZERO

	var fire_alignment: float = to_player.dot(fire_direction)
	var required_alignment: float = cos(deg_to_rad(broadside_fire_alignment_degrees))

	if fire_alignment >= required_alignment:
		return fire_direction

	return Vector3.ZERO


func _get_preferred_broadside_direction(offset_to_player: Vector3, lock_side: bool = true) -> Vector3:
	var preferred_side: int = _get_preferred_broadside_side(offset_to_player, lock_side)
	return _get_broadside_axis_for_side(preferred_side)


func _get_preferred_broadside_side(offset_to_player: Vector3, lock_side: bool) -> int:
	if offset_to_player.length_squared() < 0.01:
		return BROADSIDE_SIDE_NONE

	if _side_lock_remaining > 0.0 and _locked_broadside_side != BROADSIDE_SIDE_NONE:
		return _locked_broadside_side

	var to_player: Vector3 = offset_to_player.normalized()
	var port_direction: Vector3 = _get_port_axis()
	var starboard_direction: Vector3 = _get_starboard_axis()

	var preferred_side := BROADSIDE_SIDE_STARBOARD
	if to_player.dot(port_direction) >= to_player.dot(starboard_direction):
		preferred_side = BROADSIDE_SIDE_PORT

	if lock_side:
		_locked_broadside_side = preferred_side
		_side_lock_remaining = broadside_side_lock_duration

	return preferred_side


func _get_broadside_axis_for_side(side: int) -> Vector3:
	match side:
		BROADSIDE_SIDE_PORT:
			return _get_port_axis()
		BROADSIDE_SIDE_STARBOARD:
			return _get_starboard_axis()

	return Vector3.ZERO


func _maneuver_for_broadside(offset_to_player: Vector3, distance_to_player: float, attack_range: float, delta: float) -> void:
	if offset_to_player.length_squared() < 0.01:
		ship.brake(delta)
		return

	var to_player: Vector3 = offset_to_player.normalized()
	var desired_forward: Vector3 = _get_desired_broadside_forward(to_player)
	if desired_forward.length_squared() < 0.01:
		ship.brake(delta)
		return

	var preferred_fire_direction: Vector3 = _get_preferred_broadside_direction(offset_to_player)
	var preferred_distance: float = attack_range * broadside_preferred_distance_ratio
	var speed_scale: float = broadside_maneuver_speed_scale

	if distance_to_player < preferred_distance - broadside_distance_margin:
		speed_scale = broadside_retreat_speed_scale
		desired_forward = (desired_forward + (-to_player * broadside_radial_weight)).normalized()
	elif distance_to_player > preferred_distance + broadside_distance_margin:
		desired_forward = (desired_forward + (to_player * broadside_radial_weight)).normalized()

	var line_error: Vector3 = _get_broadside_line_error(preferred_fire_direction)
	if line_error.length_squared() > broadside_line_tolerance * broadside_line_tolerance:
		desired_forward = (desired_forward + (line_error.normalized() * broadside_line_correction_weight)).normalized()

	speed_scale = _apply_broadside_turn_slowdown(speed_scale)

	if ship.has_method("steer_along_direction_with_speed"):
		ship.steer_along_direction_with_speed(desired_forward, delta, speed_scale)
	elif ship.has_method("steer_along_direction"):
		ship.steer_along_direction(desired_forward, delta)
	else:
		ship.steer_toward(_get_player_aim_position(), delta)


func _get_player_aim_position() -> Vector3:
	if is_instance_valid(_player) and _player.has_method("get_aim_position"):
		var aim_position: Vector3 = _player.get_aim_position()
		return aim_position
	if is_instance_valid(_player):
		return _player.global_position

	return ship.global_position


func _apply_broadside_turn_slowdown(speed_scale: float) -> float:
	var turn_load: float = 0.0
	if ship.has_method("get_turn_load"):
		turn_load = float(ship.get_turn_load())

	var slowed_speed: float = speed_scale - (turn_load * broadside_turn_slowdown)
	return clampf(slowed_speed, broadside_min_maneuver_speed_scale, 1.0)


func _get_broadside_line_error(fire_direction: Vector3) -> Vector3:
	if fire_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var line_origin: Vector3 = _get_broadside_muzzle_position(fire_direction)
	var line_direction: Vector3 = fire_direction.normalized()
	line_direction.y = 0.0
	if line_direction.length_squared() < 0.01:
		return Vector3.ZERO

	var target_position: Vector3 = _get_player_aim_position()
	var to_target: Vector3 = target_position - line_origin
	var parallel_distance: float = maxf(0.0, to_target.dot(line_direction))
	var closest_point: Vector3 = line_origin + (line_direction * parallel_distance)
	var error: Vector3 = target_position - closest_point
	error.y = 0.0
	return error


func _get_desired_broadside_forward(to_player: Vector3) -> Vector3:
	var broadside_forward: Vector3 = Vector3.UP.cross(to_player)
	if broadside_forward.length_squared() < 0.01:
		return Vector3.ZERO

	broadside_forward = broadside_forward.normalized()
	var opposite_forward: Vector3 = -broadside_forward
	var current_forward: Vector3 = -ship.global_transform.basis.z

	if current_forward.dot(opposite_forward) > current_forward.dot(broadside_forward):
		return opposite_forward

	return broadside_forward


func _get_starboard_axis() -> Vector3:
	if ship.has_method("get_starboard_axis"):
		var starboard_axis: Vector3 = ship.get_starboard_axis()
		return starboard_axis

	var fallback_axis: Vector3 = ship.global_transform.basis.x
	fallback_axis.y = 0.0
	return fallback_axis.normalized()


func _get_port_axis() -> Vector3:
	if ship.has_method("get_port_axis"):
		var port_axis: Vector3 = ship.get_port_axis()
		return port_axis

	return -_get_starboard_axis()


func _fire_projectile(damage: int, fire_direction: Vector3) -> void:
	if enemy_cannon_ball_scene == null or not is_instance_valid(_player):
		return

	var projectile := enemy_cannon_ball_scene.instantiate()
	if not projectile is Node3D:
		projectile.queue_free()
		return

	var projectile_node := projectile as Node3D
	var start_position: Vector3 = _get_broadside_muzzle_position(fire_direction)
	var shot_direction: Vector3 = fire_direction.normalized()
	shot_direction.y = 0.0

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile)

	projectile_node.global_position = start_position

	if projectile.has_method("launch"):
		projectile.launch(shot_direction, ship, projectile_speed, damage)


func _get_broadside_muzzle_position(fire_direction: Vector3) -> Vector3:
	if ship.has_method("get_broadside_cannon_position"):
		return ship.get_broadside_cannon_position(
			fire_direction,
			broadside_muzzle_offset,
			broadside_muzzle_height
		)

	var side_direction: Vector3 = fire_direction.normalized()
	side_direction.y = 0.0
	return ship.global_position + (side_direction * broadside_muzzle_offset) + Vector3(0.0, broadside_muzzle_height, 0.0)


func _show_broadside_debug(fire_direction: Vector3) -> void:
	if not debug_broadside_fire:
		return
	if _debug_message_cooldown_remaining > 0.0:
		return

	var starboard_direction: Vector3 = _get_starboard_axis()
	var side_name: String = "tribord"
	if fire_direction.normalized().dot(starboard_direction) < 0.0:
		side_name = "babord"

	print("Tir ennemi %s" % side_name)
	_debug_message_cooldown_remaining = debug_broadside_fire_interval


func _update_broadside_debug_lines(offset_to_player: Vector3) -> void:
	if not debug_show_broadside_lines:
		_clear_broadside_debug_lines()
		return

	var fire_direction: Vector3 = _get_preferred_broadside_direction(offset_to_player, false)
	if fire_direction == Vector3.ZERO:
		_clear_broadside_debug_lines()
		return

	var line_origin: Vector3 = _get_broadside_muzzle_position(fire_direction)
	var line_direction: Vector3 = fire_direction.normalized()
	line_direction.y = 0.0
	if line_direction.length_squared() < 0.01:
		_clear_broadside_debug_lines()
		return

	var target_position: Vector3 = _get_player_aim_position()
	var to_target: Vector3 = target_position - line_origin
	var parallel_distance: float = maxf(0.0, to_target.dot(line_direction))
	var closest_point: Vector3 = line_origin + (line_direction * parallel_distance)
	var line_end: Vector3 = line_origin + (line_direction * debug_broadside_line_length)
	var shot_color: Color = Color(0.2, 0.45, 1.0, 1.0)
	if fire_direction.normalized().dot(_get_starboard_axis()) >= 0.0:
		shot_color = Color(1.0, 0.25, 0.18, 1.0)

	var line_mesh: ImmediateMesh = ImmediateMesh.new()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _get_debug_line_material())
	line_mesh.surface_set_color(shot_color)
	line_mesh.surface_add_vertex(line_origin)
	line_mesh.surface_add_vertex(line_end)
	line_mesh.surface_set_color(Color(0.35, 1.0, 0.35, 1.0))
	line_mesh.surface_add_vertex(closest_point)
	line_mesh.surface_add_vertex(target_position)
	line_mesh.surface_end()

	var line_instance: MeshInstance3D = _get_debug_line_instance()
	line_instance.global_transform = Transform3D.IDENTITY
	line_instance.mesh = line_mesh
	line_instance.visible = true


func _clear_broadside_debug_lines() -> void:
	if _debug_line_instance != null and is_instance_valid(_debug_line_instance):
		_debug_line_instance.visible = false


func _update_detection_debug() -> void:
	if not debug_show_enemy_detection:
		_clear_detection_debug()
		return

	var radius := _get_detection_range()
	if radius <= 0.0:
		_clear_detection_debug()
		return

	var segment_count := maxi(12, debug_detection_segments)
	var center := ship.global_position + Vector3(0.0, debug_detection_height, 0.0)
	var ring_mesh := ImmediateMesh.new()
	ring_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _get_debug_line_material())
	ring_mesh.surface_set_color(Color(1.0, 0.82, 0.2, 1.0))

	for index in range(segment_count):
		var angle_a := (float(index) / float(segment_count)) * TAU
		var angle_b := (float(index + 1) / float(segment_count)) * TAU
		var point_a := center + Vector3(cos(angle_a) * radius, 0.0, sin(angle_a) * radius)
		var point_b := center + Vector3(cos(angle_b) * radius, 0.0, sin(angle_b) * radius)
		ring_mesh.surface_add_vertex(point_a)
		ring_mesh.surface_add_vertex(point_b)

	ring_mesh.surface_end()

	var ring_instance := _get_debug_detection_instance()
	ring_instance.global_transform = Transform3D.IDENTITY
	ring_instance.mesh = ring_mesh
	ring_instance.visible = true


func _clear_detection_debug() -> void:
	if _debug_detection_instance != null and is_instance_valid(_debug_detection_instance):
		_debug_detection_instance.visible = false


func _clear_broadside_side_lock() -> void:
	_locked_broadside_side = BROADSIDE_SIDE_NONE
	_side_lock_remaining = 0.0


func _get_debug_line_instance() -> MeshInstance3D:
	if _debug_line_instance != null and is_instance_valid(_debug_line_instance):
		return _debug_line_instance

	_debug_line_instance = MeshInstance3D.new()
	_debug_line_instance.name = "BroadsideDebugLines"
	_debug_line_instance.top_level = true
	ship.add_child(_debug_line_instance)
	return _debug_line_instance


func _get_debug_detection_instance() -> MeshInstance3D:
	if _debug_detection_instance != null and is_instance_valid(_debug_detection_instance):
		return _debug_detection_instance

	_debug_detection_instance = MeshInstance3D.new()
	_debug_detection_instance.name = "DetectionDebugRing"
	_debug_detection_instance.top_level = true
	ship.add_child(_debug_detection_instance)
	return _debug_detection_instance


func _get_debug_line_material() -> StandardMaterial3D:
	if _debug_line_material != null:
		return _debug_line_material

	_debug_line_material = StandardMaterial3D.new()
	_debug_line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_line_material.vertex_color_use_as_albedo = true
	return _debug_line_material
