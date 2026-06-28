extends Node

signal quests_changed
signal active_quest_changed(quest_id: String)
signal active_quests_changed(quest_ids: Array[String])
signal quest_progress_changed(quest_id: String, progress: int, target: int)
signal quest_completed(quest_id: String, quest_name: String)
signal quest_reward_claimed(quest_id: String, quest_name: String)

const MAX_ACTIVE_QUESTS := 3
const OBJECTIVE_ENEMY_DESTROYED := "enemy_destroyed"
const OBJECTIVE_MAP_FRAGMENTS := "map_fragments"
const OBJECTIVE_ANCIENT_RELICS := "ancient_relics"
const OBJECTIVE_CHEST_THEN_PORT := "chest_then_port"

const STARTER_QUESTS: Array[Dictionary] = [
	{
		"id": "pirate_hunt",
		"name": "Chasse pirate",
		"objective": "Détruire 3 ennemis",
		"objective_type": OBJECTIVE_ENEMY_DESTROYED,
		"target": 3,
		"reward_gold": 100,
		"reward_wood": 40,
	},
	{
		"id": "first_map_fragment",
		"name": "Premier fragment",
		"objective": "Fouiller le coffre de l'île du Fragment",
		"objective_type": OBJECTIVE_MAP_FRAGMENTS,
		"target": 1,
		"reward_gold": 80,
		"reward_wood": 0,
	},
	{
		"id": "ancient_relic",
		"name": "Relique ancienne",
		"objective": "Fouiller le coffre du Sanctuaire englouti",
		"objective_type": OBJECTIVE_ANCIENT_RELICS,
		"target": 1,
		"reward_gold": 150,
		"reward_wood": 50,
	},
	{
		"id": "return_to_port",
		"name": "Retour au port",
		"objective": "Ouvrir la cargaison perdue puis revenir au port",
		"objective_type": OBJECTIVE_CHEST_THEN_PORT,
		"target": 2,
		"reward_gold": 60,
		"reward_wood": 20,
	},
]

var active_quest_ids: Array[String] = []
var _quest_order: Array[String] = []
var _quest_configs: Dictionary = {}
var _quest_states: Dictionary = {}


func _ready() -> void:
	add_to_group("quest_system")
	_register_starter_quests()


func _register_starter_quests() -> void:
	for quest in STARTER_QUESTS:
		register_quest(quest)


func register_quest(config: Dictionary) -> void:
	var quest_id := String(config.get("id", ""))
	if quest_id.is_empty():
		return

	_quest_configs[quest_id] = config.duplicate(true)
	if not _quest_order.has(quest_id):
		_quest_order.append(quest_id)

	if not _quest_states.has(quest_id):
		_quest_states[quest_id] = _make_initial_state()

	quests_changed.emit()


func clear_quests() -> void:
	_cleanup_all_quest_objectives()
	active_quest_ids.clear()
	_quest_order.clear()
	_quest_configs.clear()
	_quest_states.clear()
	quests_changed.emit()
	active_quest_changed.emit("")
	active_quests_changed.emit(active_quest_ids)


func accept_quest(quest_id: String) -> String:
	if not _quest_configs.has(quest_id):
		return "Mission indisponible"

	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("reward_claimed", false)):
		return "Récompense récupérée"
	if bool(state.get("completed", false)):
		return "Mission terminée"
	if active_quest_ids.has(quest_id):
		return "Mission déjà active"
	if active_quest_ids.size() >= MAX_ACTIVE_QUESTS:
		_show_hud_message("Trop de missions actives", 1.8)
		return "Trop de missions actives"

	_prepare_quest_for_acceptance(quest_id)
	active_quest_ids.append(quest_id)
	_spawn_quest_objective(quest_id)
	active_quest_changed.emit(quest_id)
	active_quests_changed.emit(active_quest_ids)
	quests_changed.emit()
	_show_hud_message("Mission acceptée : %s" % _get_quest_name(quest_id), 2.0)
	return "Mission acceptée"


func claim_reward(quest_id: String) -> String:
	if not _quest_configs.has(quest_id):
		return "Mission indisponible"

	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("reward_claimed", false)):
		return "Récompense récupérée"
	if not bool(state.get("completed", false)):
		return "Mission non terminée"

	var quest: Dictionary = _get_quest_config(quest_id)
	_grant_quest_reward(quest)

	state["reward_claimed"] = true
	_quest_states[quest_id] = state
	if active_quest_ids.has(quest_id):
		active_quest_ids.erase(quest_id)
		active_quest_changed.emit(quest_id)
		active_quests_changed.emit(active_quest_ids)

	_cleanup_quest_objective(quest_id)
	quest_reward_claimed.emit(quest_id, _get_quest_name(quest_id))
	quests_changed.emit()
	var reward_message := "Récompense récupérée : %s\n+%s" % [
		_get_quest_name(quest_id),
		_build_reward_text(quest_id),
	]
	_show_hud_message(reward_message, 2.4)
	return reward_message


func record_enemy_destroyed(_enemy_type_id: String = "") -> void:
	_progress_active_objective(OBJECTIVE_ENEMY_DESTROYED, 1)


func record_treasure_resources_gained(map_fragment_amount: int, ancient_relic_amount: int) -> void:
	if map_fragment_amount > 0:
		_progress_active_objective(OBJECTIVE_MAP_FRAGMENTS, map_fragment_amount)
	if ancient_relic_amount > 0:
		_progress_active_objective(OBJECTIVE_ANCIENT_RELICS, ancient_relic_amount)


func record_quest_objective_collected(quest_id: String) -> void:
	if not active_quest_ids.has(quest_id):
		return

	var quest: Dictionary = _get_quest_config(quest_id)
	var objective_type := String(quest.get("objective_type", ""))
	match objective_type:
		OBJECTIVE_MAP_FRAGMENTS, OBJECTIVE_ANCIENT_RELICS:
			_progress_quest_objective(quest_id, objective_type, 1)
		OBJECTIVE_CHEST_THEN_PORT:
			_mark_chest_step_done(quest_id)


func record_chest_opened(_chest_id: String = "") -> void:
	for quest_id in active_quest_ids.duplicate():
		var quest: Dictionary = _get_quest_config(quest_id)
		if String(quest.get("objective_type", "")) != OBJECTIVE_CHEST_THEN_PORT:
			continue

		var state: Dictionary = _get_quest_state(quest_id)
		if int(state.get("progress", 0)) < 1:
			_mark_chest_step_done(quest_id)


func record_port_visit() -> void:
	for quest_id in active_quest_ids.duplicate():
		var quest: Dictionary = _get_quest_config(quest_id)
		if String(quest.get("objective_type", "")) != OBJECTIVE_CHEST_THEN_PORT:
			continue

		var state: Dictionary = _get_quest_state(quest_id)
		if int(state.get("progress", 0)) >= 1:
			_complete_quest(quest_id)


func get_all_quest_views() -> Array[Dictionary]:
	var views: Array[Dictionary] = []
	for quest_id in _quest_order:
		views.append(get_quest_view(quest_id))
	return views


func get_quest_view(quest_id: String) -> Dictionary:
	var quest: Dictionary = _get_quest_config(quest_id)
	var state: Dictionary = _get_quest_state(quest_id)
	var view: Dictionary = quest.duplicate(true)
	view["id"] = quest_id
	view["progress"] = int(state.get("progress", 0))
	view["target"] = int(quest.get("target", 1))
	view["completed"] = bool(state.get("completed", false))
	view["reward_claimed"] = bool(state.get("reward_claimed", false))
	view["active"] = active_quest_ids.has(quest_id)
	view["progress_text"] = _build_progress_text(quest_id)
	view["reward_text"] = _build_reward_text(quest_id)
	view["status_text"] = _build_status_text(quest_id)
	view["can_accept"] = can_accept_quest(quest_id)
	view["can_claim"] = can_claim_reward(quest_id)
	return view


func get_active_quest_summary() -> String:
	var summaries := get_active_quest_summaries()
	if summaries.is_empty():
		return ""

	var summary := ""
	for line in summaries:
		if not summary.is_empty():
			summary += "\n"
		summary += line
	return summary


func get_active_quest_summaries(limit: int = MAX_ACTIVE_QUESTS) -> Array[String]:
	var summaries: Array[String] = []
	for quest_id in active_quest_ids:
		if summaries.size() >= limit:
			break

		var state: Dictionary = _get_quest_state(quest_id)
		if bool(state.get("completed", false)):
			summaries.append("Mission terminée : %s" % _get_quest_name(quest_id))
		else:
			summaries.append("%s : %s" % [_get_quest_name(quest_id), _build_short_progress_text(quest_id)])

	return summaries


func get_active_quest_count() -> int:
	return active_quest_ids.size()


func get_max_active_quests() -> int:
	return MAX_ACTIVE_QUESTS


func can_accept_quest(quest_id: String) -> bool:
	if not _quest_configs.has(quest_id):
		return false
	if active_quest_ids.has(quest_id):
		return false
	if active_quest_ids.size() >= MAX_ACTIVE_QUESTS:
		return false

	var state: Dictionary = _get_quest_state(quest_id)
	return not bool(state.get("completed", false)) and not bool(state.get("reward_claimed", false))


func can_claim_reward(quest_id: String) -> bool:
	if not _quest_configs.has(quest_id):
		return false

	var state: Dictionary = _get_quest_state(quest_id)
	return bool(state.get("completed", false)) and not bool(state.get("reward_claimed", false))


func _progress_active_objective(objective_type: String, amount: int) -> void:
	if active_quest_ids.is_empty() or amount <= 0:
		return

	for quest_id in active_quest_ids.duplicate():
		_progress_quest_objective(quest_id, objective_type, amount)


func _progress_quest_objective(quest_id: String, objective_type: String, amount: int) -> void:
	if amount <= 0:
		return

	var quest: Dictionary = _get_quest_config(quest_id)
	if String(quest.get("objective_type", "")) != objective_type:
		return

	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("completed", false)):
		return

	var target: int = int(quest.get("target", 1))
	var progress: int = clampi(int(state.get("progress", 0)) + amount, 0, target)
	state["progress"] = progress
	_quest_states[quest_id] = state

	if progress >= target:
		_complete_quest(quest_id)
	else:
		_emit_progress(quest_id)


func _mark_chest_step_done(quest_id: String) -> void:
	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("completed", false)):
		return

	if int(state.get("progress", 0)) < 1:
		state["progress"] = 1
		_quest_states[quest_id] = state
		_emit_progress(quest_id)


func _complete_quest(quest_id: String) -> void:
	var quest: Dictionary = _get_quest_config(quest_id)
	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("completed", false)):
		return

	state["progress"] = int(quest.get("target", 1))
	state["completed"] = true
	_quest_states[quest_id] = state
	_record_mission_reputation(quest_id)
	quest_completed.emit(quest_id, _get_quest_name(quest_id))
	quests_changed.emit()
	_show_hud_message(
		"Mission terminée : %s\nRetour au port pour la récompense" % _get_quest_name(quest_id),
		2.8
	)


func _prepare_quest_for_acceptance(quest_id: String) -> void:
	if not _quest_uses_spawned_objective(quest_id):
		return

	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("completed", false)) or bool(state.get("reward_claimed", false)):
		return

	# Treasure missions must start from their temporary objective, not from old island loot history.
	state["progress"] = 0
	_quest_states[quest_id] = state


func _quest_uses_spawned_objective(quest_id: String) -> bool:
	var quest: Dictionary = _get_quest_config(quest_id)
	match String(quest.get("objective_type", "")):
		OBJECTIVE_MAP_FRAGMENTS, OBJECTIVE_ANCIENT_RELICS, OBJECTIVE_CHEST_THEN_PORT:
			return true

	return false


func _emit_progress(quest_id: String) -> void:
	var quest: Dictionary = _get_quest_config(quest_id)
	var state: Dictionary = _get_quest_state(quest_id)
	quest_progress_changed.emit(
		quest_id,
		int(state.get("progress", 0)),
		int(quest.get("target", 1))
	)
	quests_changed.emit()
	_show_hud_message(get_active_quest_summary(), 1.6)


func _make_initial_state() -> Dictionary:
	return {
		"progress": 0,
		"completed": false,
		"reward_claimed": false,
	}


func _get_quest_config(quest_id: String) -> Dictionary:
	if _quest_configs.has(quest_id):
		return _quest_configs[quest_id]

	return {}


func _get_quest_state(quest_id: String) -> Dictionary:
	if _quest_states.has(quest_id):
		return _quest_states[quest_id]

	return _make_initial_state()


func _get_quest_name(quest_id: String) -> String:
	var quest: Dictionary = _get_quest_config(quest_id)
	return String(quest.get("name", "Mission"))


func _build_progress_text(quest_id: String) -> String:
	var quest: Dictionary = _get_quest_config(quest_id)
	var state: Dictionary = _get_quest_state(quest_id)
	var progress: int = int(state.get("progress", 0))
	var target: int = int(quest.get("target", 1))

	match String(quest.get("objective_type", "")):
		OBJECTIVE_ENEMY_DESTROYED:
			return "%d/%d ennemis" % [progress, target]
		OBJECTIVE_MAP_FRAGMENTS:
			return "%d/%d fragment" % [progress, target]
		OBJECTIVE_ANCIENT_RELICS:
			return "%d/%d relique" % [progress, target]
		OBJECTIVE_CHEST_THEN_PORT:
			if progress <= 0:
				return "coffre à ouvrir"
			if progress < target:
				return "coffre ouvert, retour au port"
			return "retour au port"

	return "%d/%d" % [progress, target]


func _build_short_progress_text(quest_id: String) -> String:
	var quest: Dictionary = _get_quest_config(quest_id)
	var state: Dictionary = _get_quest_state(quest_id)
	var progress: int = int(state.get("progress", 0))
	var target: int = int(quest.get("target", 1))

	match String(quest.get("objective_type", "")):
		OBJECTIVE_CHEST_THEN_PORT:
			if progress <= 0:
				return "coffre"
			if progress < target:
				return "retour port"
			return "terminée"

	return "%d/%d" % [progress, target]


func _build_reward_text(quest_id: String) -> String:
	var quest: Dictionary = _get_quest_config(quest_id)
	var reward_parts: Array[String] = []
	var reward_gold: int = int(quest.get("reward_gold", 0))
	var reward_wood: int = int(quest.get("reward_wood", 0))
	if reward_gold > 0:
		reward_parts.append("%d or" % reward_gold)
	if reward_wood > 0:
		reward_parts.append("%d bois" % reward_wood)
	if reward_parts.is_empty():
		return "Aucune"

	var reward_text := ""
	for part in reward_parts:
		if not reward_text.is_empty():
			reward_text += ", "
		reward_text += part
	return reward_text


func _grant_quest_reward(quest: Dictionary) -> void:
	var reward_gold: int = int(quest.get("reward_gold", 0))
	var reward_wood: int = int(quest.get("reward_wood", 0))
	var game_state := _get_game_state()
	if game_state != null and game_state.has_method("add_resources"):
		game_state.add_resources(reward_gold, reward_wood)


func _build_status_text(quest_id: String) -> String:
	var state: Dictionary = _get_quest_state(quest_id)
	if bool(state.get("reward_claimed", false)):
		return "Récompense récupérée"
	if bool(state.get("completed", false)):
		return "Terminée"
	if active_quest_ids.has(quest_id):
		return "Active"
	return "Disponible"


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _record_mission_reputation(quest_id: String) -> void:
	var reputation_system := get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("record_mission_completed"):
		reputation_system.record_mission_completed(quest_id)


func _spawn_quest_objective(quest_id: String) -> void:
	var spawner := get_tree().get_first_node_in_group("quest_objective_spawner")
	if spawner != null and spawner.has_method("spawn_objective_for_quest"):
		spawner.spawn_objective_for_quest(quest_id)


func _cleanup_quest_objective(quest_id: String) -> void:
	var spawner := get_tree().get_first_node_in_group("quest_objective_spawner")
	if spawner != null and spawner.has_method("clear_objective_for_quest"):
		spawner.clear_objective_for_quest(quest_id)


func _cleanup_all_quest_objectives() -> void:
	var spawner := get_tree().get_first_node_in_group("quest_objective_spawner")
	if spawner != null and spawner.has_method("clear_all_objectives"):
		spawner.clear_all_objectives()


func _show_hud_message(message: String, duration: float) -> void:
	if message.is_empty():
		return

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, duration)
