extends Node

signal reputation_changed(points: int, rank_name: String, next_rank_name: String, current_threshold: int, next_threshold: int)
signal reputation_rank_changed(rank_name: String, points: int)

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
var _full_fleet_bonus_awarded: bool = false


func _ready() -> void:
	add_to_group("reputation_system")
	_refresh_rank()
	_emit_reputation_changed()


func add_reputation(amount: int, _reason: String = "") -> void:
	amount = maxi(0, amount)
	if amount <= 0:
		return

	var previous_rank_index := _current_rank_index
	reputation_points += amount
	_refresh_rank()
	_emit_reputation_changed()

	if _current_rank_index != previous_rank_index:
		reputation_rank_changed.emit(get_current_rank_name(), reputation_points)


func record_enemy_destroyed(enemy_type_id: String) -> void:
	var reward := DEFAULT_ENEMY_REPUTATION
	if ENEMY_REPUTATION_REWARDS.has(enemy_type_id):
		reward = int(ENEMY_REPUTATION_REWARDS[enemy_type_id])

	add_reputation(reward, "enemy_destroyed")


func record_mission_completed(_quest_id: String) -> void:
	add_reputation(MISSION_COMPLETED_REPUTATION, "mission_completed")


func record_chest_opened(is_quest_objective: bool) -> void:
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
	add_reputation(ALLY_RECRUITED_REPUTATION, "ally_recruited")

	if not _full_fleet_bonus_awarded and max_allies > 0 and fleet_count >= max_allies:
		_full_fleet_bonus_awarded = true
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


func get_reputation_view() -> Dictionary:
	return {
		"points": reputation_points,
		"rank_name": get_current_rank_name(),
		"next_rank_name": get_next_rank_name(),
		"current_threshold": get_current_rank_threshold(),
		"next_threshold": get_next_rank_threshold(),
		"progress_text": get_rank_progress_text(),
	}


func reset_reputation() -> void:
	reputation_points = 0
	_full_fleet_bonus_awarded = false
	_refresh_rank()
	_emit_reputation_changed()


func _refresh_rank() -> void:
	var rank_index := 0
	for index in range(REPUTATION_RANKS.size()):
		var rank: Dictionary = REPUTATION_RANKS[index]
		if reputation_points >= int(rank["threshold"]):
			rank_index = index

	_current_rank_index = rank_index


func _emit_reputation_changed() -> void:
	reputation_changed.emit(
		reputation_points,
		get_current_rank_name(),
		get_next_rank_name(),
		get_current_rank_threshold(),
		get_next_rank_threshold()
	)
