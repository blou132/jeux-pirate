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
@export var is_quest_objective: bool = false
@export var quest_id: String = ""

@onready var interaction_area: Area3D = $InteractionArea
@onready var name_label: Label3D = $NameLabel
@onready var chest_marker: Node3D = $Visuals/ChestMarker

var _player_in_range: bool = false
var _chest_opened: bool = false


func _ready() -> void:
	add_to_group("islands")
	_refresh_label()
	_chest_opened = _is_chest_opened()
	_refresh_chest_visual()
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


func get_explore_action_label() -> String:
	return "Fouiller l'ile"


func explore() -> Dictionary:
	if _is_chest_opened():
		_chest_opened = true
		_refresh_chest_visual()
		return _make_exploration_result(["Coffre déjà vidé"])

	_mark_chest_opened()
	_refresh_chest_visual()
	_grant_treasure_rewards()
	_record_reputation_for_chest_opened()
	_record_quest_objective_opened()
	return _make_exploration_result(_build_treasure_messages())


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
		game_state.add_treasure_resources(reward_map_fragments, reward_ancient_relics, false)


func _build_treasure_messages() -> Array:
	var messages: Array = []
	if reward_gold > 0 or reward_wood > 0:
		messages.append("Trésor trouvé : +%d or, +%d bois" % [reward_gold, reward_wood])
	if reward_map_fragments > 0:
		messages.append("Fragment de carte trouvé")
	if reward_ancient_relics > 0:
		messages.append("Relique ancienne trouvée")

	if messages.is_empty():
		messages.append("Coffre ouvert")

	return messages


func _make_exploration_result(messages: Array) -> Dictionary:
	return {
		"summary": _join_messages(messages),
		"messages": messages,
	}


func _join_messages(messages: Array) -> String:
	var summary := ""
	for message in messages:
		if not summary.is_empty():
			summary += "\n"
		summary += String(message)

	return summary


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _is_chest_opened() -> bool:
	if _chest_opened:
		return true
	if is_quest_objective:
		return false

	var game_state := _get_game_state()
	if game_state != null and game_state.has_method("is_island_chest_opened"):
		return game_state.is_island_chest_opened(_get_chest_key())

	return false


func _mark_chest_opened() -> void:
	_chest_opened = true
	if is_quest_objective:
		return

	var game_state := _get_game_state()
	if game_state != null and game_state.has_method("mark_island_chest_opened"):
		game_state.mark_island_chest_opened(_get_chest_key())


func _record_quest_objective_opened() -> void:
	if not is_quest_objective:
		return

	var quest_system := get_node_or_null("/root/QuestSystem")
	if quest_system != null and quest_system.has_method("record_quest_objective_collected"):
		quest_system.record_quest_objective_collected(quest_id)


func _record_reputation_for_chest_opened() -> void:
	var reputation_system := get_node_or_null("/root/ReputationSystem")
	if reputation_system == null:
		return

	if reputation_system.has_method("record_chest_opened"):
		reputation_system.record_chest_opened(is_quest_objective)
	if reward_ancient_relics > 0 and reputation_system.has_method("record_ancient_relic_found"):
		reputation_system.record_ancient_relic_found(reward_ancient_relics)


func _get_chest_key() -> String:
	if not chest_id.is_empty():
		return chest_id

	return str(get_path())


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
