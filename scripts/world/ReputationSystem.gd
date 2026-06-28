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

var reputation_points: int = 0
var _current_rank_index: int = 0


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
