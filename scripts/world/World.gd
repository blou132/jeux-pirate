extends Node3D

@onready var player: Node = $PlayerBoat
@onready var hud: CanvasLayer = $HUD
@onready var port_menu: CanvasLayer = $PortMenu
@onready var island_exploration_menu: CanvasLayer = $IslandExplorationMenu


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
