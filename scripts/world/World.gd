extends Node3D

@onready var player: Node = $PlayerBoat
@onready var hud: CanvasLayer = $HUD
@onready var port_menu: CanvasLayer = $PortMenu
@onready var island_exploration_menu: CanvasLayer = $IslandExplorationMenu
@onready var faction_choice_screen: CanvasLayer = $FactionChoiceScreen
@onready var fleet_manager: FleetManager = $FleetManager

var _pause_state_before_start_choice: bool = false
var _start_choice_blocking_gameplay: bool = false


func _enter_tree() -> void:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("reset_island_chests"):
		game_state.reset_island_chests()
	if game_state != null and game_state.has_method("reset_exploration_sites"):
		game_state.reset_exploration_sites()


func _ready() -> void:
	_set_initial_danger_zone()
	if hud.has_method("set_player"):
		hud.set_player(player)
	if fleet_manager != null:
		fleet_manager.setup(self, player as Node3D, hud)

	for port in get_tree().get_nodes_in_group("ports"):
		_connect_port(port)

	for island in get_tree().get_nodes_in_group("islands"):
		_connect_island(island)

	_connect_faction_choice_screen()
	call_deferred("_open_start_faction_choice_if_needed")


func _connect_faction_choice_screen() -> void:
	if faction_choice_screen == null or not faction_choice_screen.has_signal("faction_choice_confirmed"):
		return

	var callback: Callable = Callable(self, "_on_start_faction_choice_confirmed")
	if not faction_choice_screen.is_connected("faction_choice_confirmed", callback):
		faction_choice_screen.connect("faction_choice_confirmed", callback)


func _open_start_faction_choice_if_needed() -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state == null or not game_state.has_method("needs_start_faction_choice"):
		return
	if not bool(game_state.call("needs_start_faction_choice")):
		return
	if faction_choice_screen == null or not faction_choice_screen.has_method("open"):
		return

	_set_start_choice_gameplay_blocked(true)
	faction_choice_screen.call("open")


func _on_start_faction_choice_confirmed(_faction_id: String, message: String) -> void:
	_set_start_choice_gameplay_blocked(false)
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.call("show_temporary_context_message", message, 3.0)


func _set_start_choice_gameplay_blocked(blocked: bool) -> void:
	if blocked == _start_choice_blocking_gameplay:
		return

	_start_choice_blocking_gameplay = blocked
	if blocked:
		_pause_state_before_start_choice = get_tree().paused
		get_tree().paused = true
	else:
		get_tree().paused = _pause_state_before_start_choice


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
		port_menu.open(player, port)


func recruit_ally_ship() -> String:
	if fleet_manager == null:
		return "Recrutement indisponible"

	return fleet_manager.recruit_ally()


func get_ally_ship() -> Node:
	if fleet_manager == null:
		return null

	return fleet_manager.get_first_ally()


func get_ally_ships() -> Array:
	if fleet_manager == null:
		return []

	return fleet_manager.get_allies()


func get_fleet_manager() -> Node:
	return fleet_manager


func set_fleet_order(order_id: String) -> String:
	if fleet_manager == null:
		return "Ordre de flotte indisponible"

	return fleet_manager.set_order(order_id)


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


func _set_initial_danger_zone() -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("set_current_danger_zone"):
		game_state.call("set_current_danger_zone", DangerZoneCatalog.ZONE_SAFE)
