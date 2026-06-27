extends Node3D

signal interaction_requested(port: Node)
signal player_entered(port: Node)
signal player_exited(port: Node)

@export var prompt_message: String = "Appuie sur E pour ouvrir le port"

@onready var interaction_area: Area3D = $InteractionArea

var _player_in_range: bool = false


func _ready() -> void:
	add_to_group("ports")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		interaction_requested.emit(self)
		get_viewport().set_input_as_handled()


func is_player_in_range() -> bool:
	return _player_in_range


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true
	_set_hud_message(prompt_message)
	player_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = false
	_set_hud_message("")
	player_exited.emit(self)


func _set_hud_message(message: String) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_context_message"):
		hud.set_context_message(message)
