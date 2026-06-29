extends Node

signal upgrades_changed(hull_level: int, sails_level: int, cannons_level: int)

const UPGRADE_HULL := "hull"
const UPGRADE_SAILS := "sails"
const UPGRADE_CANNONS := "cannons"
const COSTS := {
	1: {"gold": 20, "wood": 10},
	2: {"gold": 40, "wood": 20},
	3: {"gold": 80, "wood": 40},
	4: {"gold": 140, "wood": 70},
	5: {"gold": 220, "wood": 110},
	6: {"gold": 320, "wood": 160},
}
const LABELS := {
	"hull": "Coque renforcée",
	"sails": "Voiles rapides",
	"cannons": "Canons améliorés",
}

var _levels_by_ship: Dictionary = {}


func _ready() -> void:
	_connect_game_state()
	_ensure_active_ship_levels()


func get_hull_level() -> int:
	return get_level(UPGRADE_HULL)


func get_sails_level() -> int:
	return get_level(UPGRADE_SAILS)


func get_cannons_level() -> int:
	return get_level(UPGRADE_CANNONS)


func get_level(upgrade_id: String) -> int:
	var levels: Dictionary = _get_active_levels()
	return int(levels.get(upgrade_id, 0))


func get_max_level(upgrade_id: String) -> int:
	if not LABELS.has(upgrade_id):
		return 0

	return ShipCatalog.get_upgrade_limit(_get_active_ship_id(), upgrade_id)


func is_max_level(upgrade_id: String) -> bool:
	return get_level(upgrade_id) >= get_max_level(upgrade_id)


func get_upgrade_status(upgrade_id: String) -> String:
	if not LABELS.has(upgrade_id):
		return "Amélioration inconnue"

	var label: String = _get_label(upgrade_id)
	var level: int = get_level(upgrade_id)
	var max_level: int = get_max_level(upgrade_id)

	if level >= max_level:
		return "%s : niv. %d/%d — niveau maximum atteint" % [label, level, max_level]

	var next_level: int = level + 1
	var cost: Dictionary = get_upgrade_cost(next_level)
	var status: String = "%s : niv. %d/%d — Coût : %d or, %d bois" % [
		label,
		level,
		max_level,
		int(cost["gold"]),
		int(cost["wood"]),
	]

	if not can_afford_next(upgrade_id):
		status += " — Ressources insuffisantes"

	return status


func can_afford_next(upgrade_id: String) -> bool:
	if is_max_level(upgrade_id):
		return false

	var next_level: int = get_level(upgrade_id) + 1
	var cost: Dictionary = get_upgrade_cost(next_level)
	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("can_afford"):
		return false

	return game_state.can_afford(int(cost["gold"]), int(cost["wood"]))


func purchase_upgrade(upgrade_id: String) -> String:
	if not LABELS.has(upgrade_id):
		return "Amélioration inconnue"

	var level: int = get_level(upgrade_id)
	if level >= get_max_level(upgrade_id):
		return "Niveau maximum atteint"

	var next_level: int = level + 1
	var cost: Dictionary = get_upgrade_cost(next_level)
	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("spend_resources"):
		return "Ressources insuffisantes"

	if not game_state.spend_resources(int(cost["gold"]), int(cost["wood"])):
		return "Ressources insuffisantes"

	var levels: Dictionary = _get_active_levels()
	levels[upgrade_id] = next_level
	_emit_upgrades_changed()
	return "%s niveau %d" % [_get_label(upgrade_id), next_level]


func get_upgrade_cost(level: int) -> Dictionary:
	if COSTS.has(level):
		var cost: Dictionary = COSTS[level]
		return cost.duplicate()

	return {}


func _emit_upgrades_changed() -> void:
	upgrades_changed.emit(get_hull_level(), get_sails_level(), get_cannons_level())


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _connect_game_state() -> void:
	var game_state: Node = _get_game_state()
	if game_state == null:
		return

	var callback: Callable = Callable(self, "_on_player_ship_changed")
	if game_state.has_signal("player_ship_changed") and not game_state.is_connected("player_ship_changed", callback):
		game_state.connect("player_ship_changed", callback)


func _on_player_ship_changed(_ship_id: String, _ship_name: String) -> void:
	_ensure_active_ship_levels()
	_emit_upgrades_changed()


func _get_active_ship_id() -> String:
	var game_state: Node = _get_game_state()
	if game_state != null and game_state.has_method("get_active_player_ship_id"):
		return String(game_state.get_active_player_ship_id())

	return ShipCatalog.STARTING_SHIP_ID


func _get_active_levels() -> Dictionary:
	var ship_id: String = _get_active_ship_id()
	if not _levels_by_ship.has(ship_id):
		_levels_by_ship[ship_id] = _get_empty_levels()

	var levels: Dictionary = _levels_by_ship[ship_id]
	return levels


func _ensure_active_ship_levels() -> void:
	_get_active_levels()


func _get_empty_levels() -> Dictionary:
	return {
		UPGRADE_HULL: 0,
		UPGRADE_SAILS: 0,
		UPGRADE_CANNONS: 0,
	}


func _get_label(upgrade_id: String) -> String:
	return String(LABELS.get(upgrade_id, upgrade_id))
