class_name Island
extends Node3D

signal interaction_requested(island: Island)
signal player_entered(island: Island)
signal player_exited(island: Island)

@export var island_name: String = "Île inconnue"
@export var prompt_message_template: String = "Appuie sur E pour explorer : %s"
@export var chest_id: String = ""
@export var reward_gold: int = 0
@export var reward_wood: int = 0
@export var reward_map_fragments: int = 0
@export var reward_ancient_relics: int = 0

@onready var interaction_area: Area3D = $InteractionArea
@onready var name_label: Label3D = $NameLabel
@onready var chest_marker: Node3D = $Visuals/ChestMarker

var _player_in_range: bool = false
var _chest_opened: bool = false


func _ready() -> void:
	add_to_group("islands")
	_refresh_label()
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


func get_island_name() -> String:
	return island_name


func explore() -> String:
	if _chest_opened:
		return "Coffre déjà vidé"

	_chest_opened = true
	_refresh_chest_visual()
	_grant_treasure_rewards()
	return _build_treasure_summary()


func _refresh_label() -> void:
	if name_label != null:
		name_label.text = island_name


func _refresh_chest_visual() -> void:
	if chest_marker != null:
		chest_marker.visible = not _chest_opened


func _grant_treasure_rewards() -> void:
	var game_state := _get_game_state()
	if game_state == null:
		return

	if game_state.has_method("add_resources"):
		game_state.add_resources(reward_gold, reward_wood)

	if game_state.has_method("add_treasure_resources"):
		game_state.add_treasure_resources(reward_map_fragments, reward_ancient_relics)


func _build_treasure_summary() -> String:
	var parts: Array = []
	if reward_gold > 0:
		parts.append("+%d or" % reward_gold)
	if reward_wood > 0:
		parts.append("+%d bois" % reward_wood)
	if reward_map_fragments > 0:
		parts.append("+%d fragment de carte" % reward_map_fragments)
	if reward_ancient_relics > 0:
		parts.append("+%d relique ancienne" % reward_ancient_relics)

	if parts.is_empty():
		return "Coffre ouvert"

	var summary := ""
	for part in parts:
		if not summary.is_empty():
			summary += ", "
		summary += String(part)

	return "Butin reçu : %s" % summary


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true
	_set_hud_message(prompt_message_template % island_name)
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
