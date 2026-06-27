extends Node

signal upgrades_changed(hull_level: int, sails_level: int, cannons_level: int)

const MAX_LEVEL := 3
const UPGRADE_HULL := "hull"
const UPGRADE_SAILS := "sails"
const UPGRADE_CANNONS := "cannons"
const COSTS := {
	1: {"gold": 20, "wood": 10},
	2: {"gold": 40, "wood": 20},
	3: {"gold": 80, "wood": 40},
}
const LABELS := {
	"hull": "Coque renforcée",
	"sails": "Voiles rapides",
	"cannons": "Canons améliorés",
}

var _levels := {
	"hull": 0,
	"sails": 0,
	"cannons": 0,
}


func get_hull_level() -> int:
	return get_level(UPGRADE_HULL)


func get_sails_level() -> int:
	return get_level(UPGRADE_SAILS)


func get_cannons_level() -> int:
	return get_level(UPGRADE_CANNONS)


func get_level(upgrade_id: String) -> int:
	return int(_levels.get(upgrade_id, 0))


func is_max_level(upgrade_id: String) -> bool:
	return get_level(upgrade_id) >= MAX_LEVEL


func get_upgrade_status(upgrade_id: String) -> String:
	if not _levels.has(upgrade_id):
		return "Amélioration inconnue"

	var label := _get_label(upgrade_id)
	var level := get_level(upgrade_id)

	if level >= MAX_LEVEL:
		return "%s: niveau %d/%d - maximum atteint" % [label, level, MAX_LEVEL]

	var next_level := level + 1
	var cost := COSTS[next_level]
	var status := "%s: niveau %d/%d - prochain %d or + %d bois" % [
		label,
		level,
		MAX_LEVEL,
		cost["gold"],
		cost["wood"],
	]

	if not can_afford_next(upgrade_id):
		status += " - ressources insuffisantes"

	return status


func can_afford_next(upgrade_id: String) -> bool:
	if is_max_level(upgrade_id):
		return false

	var next_level := get_level(upgrade_id) + 1
	var cost := COSTS[next_level]
	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("can_afford"):
		return false

	return game_state.can_afford(cost["gold"], cost["wood"])


func purchase_upgrade(upgrade_id: String) -> String:
	if not _levels.has(upgrade_id):
		return "Amélioration inconnue"

	var level := get_level(upgrade_id)
	if level >= MAX_LEVEL:
		return "Niveau maximum atteint"

	var next_level := level + 1
	var cost := COSTS[next_level]
	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("spend_resources"):
		return "Ressources insuffisantes"

	if not game_state.spend_resources(cost["gold"], cost["wood"]):
		return "Ressources insuffisantes"

	_levels[upgrade_id] = next_level
	_emit_upgrades_changed()
	return "%s niveau %d" % [_get_label(upgrade_id), next_level]


func _emit_upgrades_changed() -> void:
	upgrades_changed.emit(get_hull_level(), get_sails_level(), get_cannons_level())


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _get_label(upgrade_id: String) -> String:
	return String(LABELS.get(upgrade_id, upgrade_id))
