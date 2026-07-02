class_name ExplorationSite
extends Node3D

signal interaction_requested(site: ExplorationSite)
signal player_entered(site: ExplorationSite)
signal player_exited(site: ExplorationSite)

@export var site_id: String = ""
@export var site_name: String = "Site inconnu"
@export var site_type: String = "site"
@export var danger_zone: String = TreasureCatalog.DANGER_SAFE
@export var treasure_id: String = TreasureCatalog.TREASURE_POUCH
@export var prompt_message_template: String = "Appuie sur E pour explorer : %s"

@onready var interaction_area: Area3D = $InteractionArea
@onready var name_label: Label3D = $NameLabel
@onready var marker: Node3D = $Visuals/Marker

var _player_in_range: bool = false
var _explored: bool = false


func _ready() -> void:
	add_to_group("exploration_sites")
	_ensure_treasure_matches_danger_zone()
	_refresh_label()
	_explored = _is_explored()
	_refresh_visual()
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
	return site_name


func get_explore_action_label() -> String:
	return "Explorer le site"


func get_exploration_hint_text() -> String:
	if _is_explored():
		return "Site deja explore\n%s deja recupere" % TreasureCatalog.get_treasure_name(treasure_id)

	var lines: Array[String] = [
		"Type : %s" % site_type,
		"Zone : %s" % danger_zone,
		"Tresor : %s" % TreasureCatalog.get_treasure_name(treasure_id),
		"Requis : %s" % TreasureCatalog.get_requirement_text(treasure_id),
		"Recompenses : %s" % TreasureCatalog.get_reward_text(treasure_id),
	]
	var reward_multiplier: float = _get_reward_multiplier()
	if reward_multiplier > 1.0:
		lines.append("Bonus zone : x%.2f" % reward_multiplier)
	return _join_messages(lines)


func explore() -> Dictionary:
	if _is_explored():
		_explored = true
		_refresh_visual()
		return _make_exploration_result([
			"Site deja explore",
			"%s deja recupere" % TreasureCatalog.get_treasure_name(treasure_id),
		])

	var game_state: Node = _get_game_state()
	if game_state == null:
		return _make_exploration_result(["Exploration indisponible"])

	var block_reason: String = _get_unlock_block_reason(game_state)
	if not block_reason.is_empty():
		return _make_exploration_result([
			block_reason,
			_build_requirement_status(game_state),
			"Aucun fragment consomme",
		])

	var rewards: Dictionary = TreasureCatalog.get_rewards(treasure_id)
	var cargo_reward: Dictionary = rewards.get("cargo", {})
	var cargo_block_reason: String = _get_cargo_block_reason(game_state, cargo_reward)
	if not cargo_block_reason.is_empty():
		return _make_exploration_result([
			cargo_block_reason,
			"Vendez des marchandises avant d'explorer ce site",
		])

	if not _spend_unlock_requirements(game_state):
		return _make_exploration_result([
			"Fragments de carte insuffisants",
			_build_requirement_status(game_state),
			"Aucun fragment consomme",
		])

	if not _mark_explored():
		return _make_exploration_result([
			"Site deja explore",
			"%s deja recupere" % TreasureCatalog.get_treasure_name(treasure_id),
		])

	_refresh_visual()
	_grant_rewards(game_state, rewards)
	var renown_gained: int = _grant_renown()

	return _make_exploration_result(_build_reward_messages(rewards, renown_gained))


func _refresh_label() -> void:
	if name_label == null:
		return

	name_label.text = "%s\n%s - %s" % [
		site_name,
		danger_zone,
		TreasureCatalog.get_treasure_name(treasure_id),
	]


func _ensure_treasure_matches_danger_zone() -> void:
	if TreasureCatalog.is_treasure_available_in_danger_zone(treasure_id, danger_zone):
		return

	treasure_id = TreasureCatalog.get_default_treasure_for_danger_zone(danger_zone)


func _refresh_visual() -> void:
	if marker != null:
		marker.visible = not _explored


func _get_unlock_block_reason(game_state: Node) -> String:
	var required_fragments: int = TreasureCatalog.get_required_map_fragments(treasure_id)
	var required_relics: int = TreasureCatalog.get_required_ancient_relics(treasure_id)
	var current_fragments: int = 0
	var current_relics: int = 0
	if game_state.has_method("get_map_fragments"):
		current_fragments = int(game_state.call("get_map_fragments"))
	if game_state.has_method("get_ancient_relics"):
		current_relics = int(game_state.call("get_ancient_relics"))

	if current_fragments < required_fragments:
		return "Fragments de carte insuffisants"
	if current_relics < required_relics:
		return "Relique ancienne requise"

	return ""


func _build_requirement_status(game_state: Node) -> String:
	var required_fragments: int = TreasureCatalog.get_required_map_fragments(treasure_id)
	var required_relics: int = TreasureCatalog.get_required_ancient_relics(treasure_id)
	var current_fragments: int = 0
	var current_relics: int = 0
	if game_state.has_method("get_map_fragments"):
		current_fragments = int(game_state.call("get_map_fragments"))
	if game_state.has_method("get_ancient_relics"):
		current_relics = int(game_state.call("get_ancient_relics"))

	if required_fragments <= 0 and required_relics <= 0:
		return "Aucun fragment requis"

	var parts: Array[String] = []
	if required_fragments > 0:
		parts.append("Fragments : %d/%d" % [current_fragments, required_fragments])
	if required_relics > 0:
		parts.append("Reliques : %d/%d" % [current_relics, required_relics])

	return ", ".join(parts)


func _spend_unlock_requirements(game_state: Node) -> bool:
	var cost: Dictionary = _build_unlock_cost()
	if not game_state.has_method("spend_cost"):
		return true

	return bool(game_state.call("spend_cost", cost))


func _build_unlock_cost() -> Dictionary:
	return {
		"map_fragments": TreasureCatalog.get_required_map_fragments(treasure_id),
		"ancient_relics": TreasureCatalog.get_required_ancient_relics(treasure_id),
	}


func _get_cargo_block_reason(game_state: Node, cargo_reward: Dictionary) -> String:
	if cargo_reward.is_empty():
		return ""
	if not game_state.has_method("get_cargo_free"):
		return ""

	var required_space: int = 0
	for item_id in cargo_reward.keys():
		var item_key: String = String(item_id)
		var amount: int = maxi(0, int(cargo_reward.get(item_key, 0)))
		if amount > 0 and CargoCatalog.has_good(item_key):
			required_space += CargoCatalog.get_good_weight(item_key) * amount

	var free_space: int = int(game_state.call("get_cargo_free"))
	if required_space > free_space:
		return "Cargaison insuffisante : %d espace requis" % required_space

	return ""


func _grant_rewards(game_state: Node, rewards: Dictionary) -> void:
	var gold_reward: int = _scale_zone_reward(maxi(0, int(rewards.get("gold", 0))))
	var wood_reward: int = _scale_zone_reward(maxi(0, int(rewards.get("wood", 0))))
	var map_fragment_reward: int = maxi(0, int(rewards.get("map_fragments", 0)))
	var relic_reward: int = maxi(0, int(rewards.get("ancient_relics", 0)))
	var cargo_reward: Dictionary = rewards.get("cargo", {})

	if game_state.has_method("add_resources"):
		game_state.call("add_resources", gold_reward, wood_reward)
	if game_state.has_method("add_treasure_resources"):
		game_state.call("add_treasure_resources", map_fragment_reward, relic_reward, true)
	if game_state.has_method("add_cargo"):
		for item_id in cargo_reward.keys():
			var item_key: String = String(item_id)
			var amount: int = maxi(0, int(cargo_reward.get(item_key, 0)))
			if amount > 0:
				game_state.call("add_cargo", item_key, amount)


func _grant_renown() -> int:
	var renown_reward: int = _scale_zone_reward(TreasureCatalog.get_renown_reward(treasure_id))
	if renown_reward <= 0:
		return 0

	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("record_treasure_discovered"):
		return int(reputation_system.call("record_treasure_discovered", treasure_id, renown_reward))
	if reputation_system != null and reputation_system.has_method("add_reputation"):
		return int(reputation_system.call("add_reputation", renown_reward, "treasure_discovered"))

	return 0


func _build_reward_messages(rewards: Dictionary, renown_gained: int) -> Array[String]:
	var messages: Array[String] = [
		"Tresor decouvert : %s" % TreasureCatalog.get_treasure_name(treasure_id),
		"Site : %s" % site_name,
	]
	var reward_text: String = TreasureCatalog.get_reward_text(treasure_id)
	if not reward_text.is_empty():
		messages.append("Recompenses : %s" % reward_text)
	var reward_multiplier: float = _get_reward_multiplier()
	if reward_multiplier > 1.0:
		messages.append("Bonus de zone : x%.2f sur or, bois et renom" % reward_multiplier)
	if renown_gained <= 0 and TreasureCatalog.get_renown_reward(treasure_id) > 0:
		messages.append("Renom au maximum")

	return messages


func _get_reward_multiplier() -> float:
	return DangerZoneCatalog.get_reward_multiplier(danger_zone)


func _scale_zone_reward(base_reward: int) -> int:
	if base_reward <= 0:
		return 0

	return roundi(float(base_reward) * _get_reward_multiplier())


func _make_exploration_result(messages: Array[String]) -> Dictionary:
	return {
		"summary": _join_messages(messages),
		"messages": messages,
	}


func _join_messages(messages: Array[String]) -> String:
	var summary: String = ""
	for message in messages:
		if not summary.is_empty():
			summary += "\n"
		summary += String(message)

	return summary


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _is_explored() -> bool:
	if _explored:
		return true

	var game_state: Node = _get_game_state()
	if game_state != null and game_state.has_method("is_exploration_site_explored"):
		return bool(game_state.call("is_exploration_site_explored", _get_site_key()))

	return false


func _mark_explored() -> bool:
	_explored = true
	var game_state: Node = _get_game_state()
	if game_state != null and game_state.has_method("mark_exploration_site_explored"):
		return bool(game_state.call("mark_exploration_site_explored", _get_site_key(), treasure_id, danger_zone))

	return true


func _get_site_key() -> String:
	if not site_id.is_empty():
		return site_id

	return str(get_path())


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true
	_set_hud_message(prompt_message_template % site_name)
	player_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = false
	_set_hud_message("")
	player_exited.emit(self)


func _set_hud_message(message: String) -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_context_message"):
		hud.call("set_context_message", message)
