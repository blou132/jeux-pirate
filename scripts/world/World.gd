extends Node3D

const ALLY_RECRUIT_GOLD_COST := 150
const ALLY_RECRUIT_WOOD_COST := 60

@export var ally_ship_scene: PackedScene = preload("res://scenes/boats/AllyShip.tscn")
@export var ally_spawn_offset_from_port: Vector3 = Vector3(7.0, 0.0, -6.0)

@onready var player: Node = $PlayerBoat
@onready var hud: CanvasLayer = $HUD
@onready var port_menu: CanvasLayer = $PortMenu
@onready var island_exploration_menu: CanvasLayer = $IslandExplorationMenu

var _ally_ship: Node3D


func _enter_tree() -> void:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("reset_island_chests"):
		game_state.reset_island_chests()


func _ready() -> void:
	if hud.has_method("set_player"):
		hud.set_player(player)

	for port in get_tree().get_nodes_in_group("ports"):
		_connect_port(port)

	for island in get_tree().get_nodes_in_group("islands"):
		_connect_island(island)


func _connect_port(port: Node) -> void:
	if not port.has_signal("interaction_requested"):
		return

	var callback := Callable(self, "_on_port_interaction_requested")
	if not port.is_connected("interaction_requested", callback):
		port.connect("interaction_requested", callback)


func _on_port_interaction_requested(port: Node) -> void:
	if port.has_method("is_player_in_range") and not port.is_player_in_range():
		return

	if port_menu.has_method("open"):
		port_menu.open(player)


func recruit_ally_ship() -> String:
	_cleanup_ally_reference()
	if _ally_ship != null:
		return "Un allié est déjà recruté"

	var game_state := get_node_or_null("/root/GameState")
	if game_state == null or not game_state.has_method("spend_resources"):
		return "Recrutement indisponible"
	if ally_ship_scene == null:
		return "Recrutement indisponible"

	var ally := ally_ship_scene.instantiate()
	if not ally is Node3D:
		ally.queue_free()
		return "Recrutement indisponible"
	if not game_state.spend_resources(ALLY_RECRUIT_GOLD_COST, ALLY_RECRUIT_WOOD_COST):
		ally.queue_free()
		return "Ressources insuffisantes — coût : 150 or, 60 bois"

	var ally_node := ally as Node3D
	add_child(ally_node)
	ally_node.global_position = _get_ally_spawn_position()
	ally_node.global_rotation = _get_ally_spawn_rotation()
	_ally_ship = ally_node
	if ally.has_signal("destroyed"):
		ally.connect("destroyed", Callable(self, "_on_ally_ship_destroyed").bind(ally_node))

	if hud.has_method("set_ally_ship"):
		hud.set_ally_ship(ally_node)
	_show_hud_message("Sloop allié recruté", 2.0)
	return "Sloop allié recruté"


func _connect_island(island: Node) -> void:
	if not island.has_signal("interaction_requested"):
		return

	var callback := Callable(self, "_on_island_interaction_requested")
	if not island.is_connected("interaction_requested", callback):
		island.connect("interaction_requested", callback)


func _on_island_interaction_requested(island: Node) -> void:
	if island.has_method("is_player_in_range") and not island.is_player_in_range():
		return

	if island_exploration_menu.has_method("open"):
		island_exploration_menu.open(island)


func _cleanup_ally_reference() -> void:
	if _ally_ship != null and not is_instance_valid(_ally_ship):
		_ally_ship = null


func _on_ally_ship_destroyed(ally_ship: Node) -> void:
	if _ally_ship == ally_ship:
		_ally_ship = null

	if hud.has_method("set_ally_ship"):
		hud.set_ally_ship(null)
	_show_hud_message("Allié détruit", 2.2)


func _get_ally_spawn_position() -> Vector3:
	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		var spawn_position := port.global_position + ally_spawn_offset_from_port
		spawn_position.y = 0.0
		return spawn_position

	if player is Node3D:
		var fallback_position := (player as Node3D).global_position + Vector3(7.0, 0.0, -6.0)
		fallback_position.y = 0.0
		return fallback_position

	return Vector3.ZERO


func _get_ally_spawn_rotation() -> Vector3:
	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		return port.global_rotation
	if player is Node3D:
		return (player as Node3D).global_rotation

	return Vector3.ZERO


func _show_hud_message(message: String, duration: float) -> void:
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, duration)
