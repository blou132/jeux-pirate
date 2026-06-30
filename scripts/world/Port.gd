extends Node3D

signal interaction_requested(port: Node)
signal player_entered(port: Node)
signal player_exited(port: Node)

@export var prompt_message: String = "Appuie sur E pour ouvrir le port"
@export var port_id: String = PortCatalog.STARTING_PORT_ID

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


func get_port_id() -> String:
	if not PortCatalog.has_port(port_id):
		return PortCatalog.STARTING_PORT_ID

	return port_id


func get_port_name() -> String:
	return PortCatalog.get_port_name(get_port_id())


func get_port_category() -> String:
	return PortCatalog.get_port_category(get_port_id())


func get_port_danger_zone() -> String:
	return PortCatalog.get_port_danger_zone(get_port_id())


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true
	_set_hud_message(_build_prompt_message())
	_record_port_visit()
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


func _build_prompt_message() -> String:
	var base_message: String = prompt_message
	if base_message.is_empty():
		base_message = "Appuie sur E pour ouvrir le port"

	return "%s\n%s - %s" % [
		base_message,
		get_port_category(),
		get_port_danger_zone(),
	]


func _record_port_visit() -> void:
	var quest_system := get_node_or_null("/root/QuestSystem")
	if quest_system != null and quest_system.has_method("record_port_visit"):
		quest_system.record_port_visit()
