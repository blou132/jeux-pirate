extends Node3D

@export var cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/CannonBall.tscn")
@export var cooldown: float = 0.8
@export var shot_speed: float = 30.0
@export var damage: int = 25
@export var cannon_damage_bonus_per_level: int = 8

@onready var port_muzzle: Marker3D = $PortMuzzle
@onready var starboard_muzzle: Marker3D = $StarboardMuzzle

var _port_cooldown: float = 0.0
var _starboard_cooldown: float = 0.0
var _base_damage: int
var cannon_count: int = 1


func _ready() -> void:
	_base_damage = damage
	_connect_game_state()
	_connect_upgrade_system()


func _process(delta: float) -> void:
	_port_cooldown = maxf(0.0, _port_cooldown - delta)
	_starboard_cooldown = maxf(0.0, _starboard_cooldown - delta)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_fire():
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			fire_port()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			fire_starboard()


func fire_port() -> void:
	if _port_cooldown > 0.0 or not _can_fire():
		return

	_fire(port_muzzle, -global_transform.basis.x)
	_port_cooldown = cooldown


func fire_starboard() -> void:
	if _starboard_cooldown > 0.0 or not _can_fire():
		return

	_fire(starboard_muzzle, global_transform.basis.x)
	_starboard_cooldown = cooldown


func _fire(muzzle: Marker3D, direction: Vector3) -> void:
	if cannon_ball_scene == null:
		return

	var cannon_ball := cannon_ball_scene.instantiate()
	if not cannon_ball is Node3D:
		return

	var source := get_parent()
	var ball_node := cannon_ball as Node3D
	ball_node.global_position = muzzle.global_position

	if cannon_ball.has_method("launch"):
		cannon_ball.launch(direction, source, shot_speed, damage)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(cannon_ball)


func _can_fire() -> bool:
	var owner := get_parent()
	if owner != null and owner.has_method("is_destroyed") and owner.is_destroyed():
		return false

	return true


func _connect_upgrade_system() -> void:
	var upgrade_system := get_node_or_null("/root/UpgradeSystem")
	if upgrade_system == null:
		return

	var callback := Callable(self, "_on_upgrades_changed")
	if upgrade_system.has_signal("upgrades_changed") and not upgrade_system.is_connected("upgrades_changed", callback):
		upgrade_system.connect("upgrades_changed", callback)

	if upgrade_system.has_method("get_hull_level") and upgrade_system.has_method("get_sails_level") and upgrade_system.has_method("get_cannons_level"):
		_on_upgrades_changed(
			upgrade_system.get_hull_level(),
			upgrade_system.get_sails_level(),
			upgrade_system.get_cannons_level()
		)


func _connect_game_state() -> void:
	var game_state := get_node_or_null("/root/GameState")
	if game_state == null:
		return

	var callback := Callable(self, "_on_player_ship_changed")
	if game_state.has_signal("player_ship_changed") and not game_state.is_connected("player_ship_changed", callback):
		game_state.connect("player_ship_changed", callback)

	_apply_active_ship_data(game_state)


func _on_player_ship_changed(_ship_id: String, _ship_name: String) -> void:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null:
		_apply_active_ship_data(game_state)


func _apply_active_ship_data(game_state: Node) -> void:
	if not game_state.has_method("get_active_player_ship_data"):
		return

	var ship: Dictionary = game_state.get_active_player_ship_data()
	_base_damage = int(ship.get("cannon_damage", _base_damage))
	cannon_count = int(ship.get("cannons", cannon_count))
	_refresh_damage_from_upgrade_system()


func _refresh_damage_from_upgrade_system() -> void:
	var upgrade_system := get_node_or_null("/root/UpgradeSystem")
	if upgrade_system == null or not upgrade_system.has_method("get_cannons_level"):
		_on_upgrades_changed(0, 0, 0)
		return

	_on_upgrades_changed(0, 0, int(upgrade_system.get_cannons_level()))


func _on_upgrades_changed(_hull_level: int, _sails_level: int, cannons_level: int) -> void:
	damage = _base_damage + (cannons_level * cannon_damage_bonus_per_level)
