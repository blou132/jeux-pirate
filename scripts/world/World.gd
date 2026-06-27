extends Node3D

@onready var player: Node = $PlayerBoat
@onready var hud: CanvasLayer = $HUD
@onready var port_menu: CanvasLayer = $PortMenu


func _ready() -> void:
	if hud.has_method("set_player"):
		hud.set_player(player)

	for port in get_tree().get_nodes_in_group("ports"):
		_connect_port(port)


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
