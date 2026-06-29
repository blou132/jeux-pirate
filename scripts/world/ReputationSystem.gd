extends Node

signal reputation_changed(points: int, rank_name: String, next_rank_name: String, current_threshold: int, next_threshold: int)
signal reputation_rank_changed(rank_name: String, points: int)
signal pirate_title_changed(title_name: String, title_score: int)

const REPUTATION_RANKS: Array[Dictionary] = [
	{"name": "Inconnu", "threshold": 0},
	{"name": "Recherché", "threshold": 100},
	{"name": "Craint", "threshold": 250},
	{"name": "Redouté", "threshold": 500},
	{"name": "Célèbre", "threshold": 900},
	{"name": "Légendaire", "threshold": 1400},
	{"name": "Fléau des mers", "threshold": 2200},
	{"name": "Roi des pirates", "threshold": 3500},
]

const PIRATE_TITLES: Array[Dictionary] = [
	{"name": "Loup de mer", "threshold": 0},
	{"name": "Capitaine", "threshold": 120},
	{"name": "Seigneur des vagues", "threshold": 300},
	{"name": "Maître des flottes", "threshold": 600},
	{"name": "Conquérant des océans", "threshold": 1000},
	{"name": "Fléau des mers", "threshold": 1500},
	{"name": "Souverain des océans", "threshold": 2300},
	{"name": "Roi des pirates", "threshold": 3500},
	{"name": "Empereur des mers", "threshold": 5000},
	{"name": "Légende éternelle", "threshold": 7000},
]

const ENEMY_REPUTATION_REWARDS := {
	"small_pirate": 10,
	"brigantine": 25,
	"heavy_patrol": 50,
}

const DEFAULT_ENEMY_REPUTATION := 25
const MISSION_COMPLETED_REPUTATION := 40
const PERMANENT_CHEST_REPUTATION := 10
const QUEST_CHEST_REPUTATION := 15
const ANCIENT_RELIC_REPUTATION := 75
const ALLY_RECRUITED_REPUTATION := 20
const FULL_FLEET_REPUTATION := 100

var reputation_points: int = 0
var _current_rank_index: int = 0
var _current_title_index: int = 0
var _highest_ally_slot_reputation_claimed: int = 0
var _full_fleet_reputation_claimed: bool = false
var _enemies_destroyed: int = 0
var _missions_completed: int = 0
var _treasures_found: int = 0
var _max_fleet_size_reached: int = 0


func _ready() -> void:
	add_to_group("reputation_system")
	_refresh_rank()
	_refresh_title()
	_emit_reputation_changed()


func add_reputation(amount: int, _reason: String = "") -> void:
	amount = maxi(0, amount)
	if amount <= 0:
		return

	var previous_rank_index := _current_rank_index
	var previous_title_index := _current_title_index
	reputation_points += amount
	_refresh_rank()
	_refresh_title()
	_emit_reputation_changed()

	if _current_rank_index != previous_rank_index:
		reputation_rank_changed.emit(get_current_rank_name(), reputation_points)
	if _current_title_index != previous_title_index:
		pirate_title_changed.emit(get_current_pirate_title(), get_title_score())

	_show_reputation_feedback(
		amount,
		_current_rank_index != previous_rank_index,
		_current_title_index != previous_title_index
	)


func record_enemy_destroyed(enemy_type_id: String) -> void:
	_enemies_destroyed += 1
	var reward := DEFAULT_ENEMY_REPUTATION
	if ENEMY_REPUTATION_REWARDS.has(enemy_type_id):
		reward = int(ENEMY_REPUTATION_REWARDS[enemy_type_id])

	add_reputation(reward, "enemy_destroyed")


func record_mission_completed(_quest_id: String) -> void:
	_missions_completed += 1
	add_reputation(MISSION_COMPLETED_REPUTATION, "mission_completed")


func record_mission_reward_claimed(_quest_id: String) -> int:
	_missions_completed += 1
	add_reputation(MISSION_COMPLETED_REPUTATION, "mission_reward_claimed")
	return MISSION_COMPLETED_REPUTATION


func record_chest_opened(is_quest_objective: bool) -> void:
	_treasures_found += 1
	if is_quest_objective:
		add_reputation(QUEST_CHEST_REPUTATION, "quest_chest_opened")
	else:
		add_reputation(PERMANENT_CHEST_REPUTATION, "chest_opened")


func record_ancient_relic_found(amount: int = 1) -> void:
	amount = maxi(0, amount)
	if amount <= 0:
		return

	add_reputation(ANCIENT_RELIC_REPUTATION * amount, "ancient_relic_found")


func record_ally_recruited(fleet_count: int, max_allies: int) -> void:
	_max_fleet_size_reached = maxi(_max_fleet_size_reached, fleet_count)

	var claimed_slot := fleet_count
	if max_allies > 0:
		claimed_slot = mini(fleet_count, max_allies)

	if claimed_slot > _highest_ally_slot_reputation_claimed:
		_highest_ally_slot_reputation_claimed = claimed_slot
		add_reputation(ALLY_RECRUITED_REPUTATION, "ally_slot_filled")

	if not _full_fleet_reputation_claimed and max_allies > 0 and fleet_count >= max_allies:
		_full_fleet_reputation_claimed = true
		add_reputation(FULL_FLEET_REPUTATION, "full_fleet")


func get_reputation_points() -> int:
	return reputation_points


func get_current_rank_name() -> String:
	var rank: Dictionary = REPUTATION_RANKS[_current_rank_index]
	return String(rank["name"])


func get_current_rank_threshold() -> int:
	var rank: Dictionary = REPUTATION_RANKS[_current_rank_index]
	return int(rank["threshold"])


func get_next_rank_name() -> String:
	var next_index := _current_rank_index + 1
	if next_index >= REPUTATION_RANKS.size():
		return "Rang maximum"

	var rank: Dictionary = REPUTATION_RANKS[next_index]
	return String(rank["name"])


func get_next_rank_threshold() -> int:
	var next_index := _current_rank_index + 1
	if next_index >= REPUTATION_RANKS.size():
		return get_current_rank_threshold()

	var rank: Dictionary = REPUTATION_RANKS[next_index]
	return int(rank["threshold"])


func get_rank_progress_text() -> String:
	var next_threshold := get_next_rank_threshold()
	if next_threshold <= get_current_rank_threshold():
		return "%d / %d" % [reputation_points, get_current_rank_threshold()]

	return "%d / %d" % [reputation_points, next_threshold]


func get_current_pirate_title() -> String:
	var title: Dictionary = PIRATE_TITLES[_current_title_index]
	return String(title["name"])


func get_title_score() -> int:
	return _calculate_title_score()


func get_next_pirate_title() -> String:
	var next_index := _current_title_index + 1
	if next_index >= PIRATE_TITLES.size():
		return "Titre maximum"

	var title: Dictionary = PIRATE_TITLES[next_index]
	return String(title["name"])


func get_next_title_threshold() -> int:
	var next_index := _current_title_index + 1
	if next_index >= PIRATE_TITLES.size():
		var current_title: Dictionary = PIRATE_TITLES[_current_title_index]
		return int(current_title["threshold"])

	var title: Dictionary = PIRATE_TITLES[next_index]
	return int(title["threshold"])


func get_title_progress_text() -> String:
	return "%d / %d" % [get_title_score(), get_next_title_threshold()]


func get_reputation_view() -> Dictionary:
	return {
		"points": reputation_points,
		"rank_name": get_current_rank_name(),
		"next_rank_name": get_next_rank_name(),
		"current_threshold": get_current_rank_threshold(),
		"next_threshold": get_next_rank_threshold(),
		"progress_text": get_rank_progress_text(),
		"title_name": get_current_pirate_title(),
		"title_score": get_title_score(),
		"next_title_name": get_next_pirate_title(),
		"title_progress_text": get_title_progress_text(),
	}


func reset_reputation() -> void:
	reputation_points = 0
	_highest_ally_slot_reputation_claimed = 0
	_full_fleet_reputation_claimed = false
	_enemies_destroyed = 0
	_missions_completed = 0
	_treasures_found = 0
	_max_fleet_size_reached = 0
	_refresh_rank()
	_refresh_title()
	_emit_reputation_changed()


func _refresh_rank() -> void:
	var rank_index := 0
	for index in range(REPUTATION_RANKS.size()):
		var rank: Dictionary = REPUTATION_RANKS[index]
		if reputation_points >= int(rank["threshold"]):
			rank_index = index

	_current_rank_index = rank_index


func _refresh_title() -> void:
	var title_score := get_title_score()
	var title_index := 0
	for index in range(PIRATE_TITLES.size()):
		var title: Dictionary = PIRATE_TITLES[index]
		if title_score >= int(title["threshold"]):
			title_index = index

	_current_title_index = title_index


func _calculate_title_score() -> int:
	return reputation_points + (_missions_completed * 20) + (_enemies_destroyed * 5) + (_treasures_found * 10) + (_max_fleet_size_reached * 20)


func _show_reputation_feedback(amount: int, rank_changed: bool, title_changed: bool) -> void:
	var messages: Array[String] = ["+%d réputation" % amount]
	if rank_changed:
		messages.append("Réputation augmentée : %s" % get_current_rank_name())
	if title_changed:
		messages.append("Nouveau titre : %s" % get_current_pirate_title())

	var duration := 1.5
	if messages.size() > 1:
		duration = 2.5

	_show_hud_message(_join_messages(messages), duration)


func _join_messages(messages: Array[String]) -> String:
	var text := ""
	for message in messages:
		if not text.is_empty():
			text += "\n"
		text += message

	return text


func _show_hud_message(message: String, duration: float) -> void:
	if message.is_empty():
		return

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, duration)


func _emit_reputation_changed() -> void:
	reputation_changed.emit(
		reputation_points,
		get_current_rank_name(),
		get_next_rank_name(),
		get_current_rank_threshold(),
		get_next_rank_threshold()
	)
