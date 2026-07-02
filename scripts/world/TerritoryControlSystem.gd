extends Node

signal zone_control_changed(zone_id: String, control: Dictionary)
signal dominant_faction_changed(zone_id: String, faction_id: String, faction_name: String, message: String)

@export var debug_territory_control: bool = false

const MAX_INFLUENCE_TOTAL: int = 100

const INITIAL_INFLUENCE: Dictionary = {
	DangerZoneCatalog.ZONE_SAFE: {
		FactionCatalog.FACTION_NAVY: 45,
		FactionCatalog.FACTION_MERCHANTS: 45,
		FactionCatalog.FACTION_PIRATES: 5,
		FactionCatalog.FACTION_SMUGGLERS: 5,
		FactionCatalog.FACTION_ABYSS_CULT: 0,
	},
	DangerZoneCatalog.ZONE_WATCHED: {
		FactionCatalog.FACTION_NAVY: 35,
		FactionCatalog.FACTION_MERCHANTS: 35,
		FactionCatalog.FACTION_PIRATES: 15,
		FactionCatalog.FACTION_SMUGGLERS: 15,
		FactionCatalog.FACTION_ABYSS_CULT: 0,
	},
	DangerZoneCatalog.ZONE_CONTESTED: {
		FactionCatalog.FACTION_PIRATES: 40,
		FactionCatalog.FACTION_NAVY: 25,
		FactionCatalog.FACTION_SMUGGLERS: 25,
		FactionCatalog.FACTION_MERCHANTS: 10,
		FactionCatalog.FACTION_ABYSS_CULT: 0,
	},
	DangerZoneCatalog.ZONE_HOSTILE: {
		FactionCatalog.FACTION_PIRATES: 45,
		FactionCatalog.FACTION_SMUGGLERS: 25,
		FactionCatalog.FACTION_ABYSS_CULT: 20,
		FactionCatalog.FACTION_NAVY: 10,
		FactionCatalog.FACTION_MERCHANTS: 0,
	},
	DangerZoneCatalog.ZONE_DEADLY: {
		FactionCatalog.FACTION_PIRATES: 40,
		FactionCatalog.FACTION_ABYSS_CULT: 45,
		FactionCatalog.FACTION_SMUGGLERS: 15,
		FactionCatalog.FACTION_NAVY: 0,
		FactionCatalog.FACTION_MERCHANTS: 0,
	},
	DangerZoneCatalog.ZONE_LEGENDARY: {
		FactionCatalog.FACTION_ABYSS_CULT: 60,
		FactionCatalog.FACTION_PIRATES: 30,
		FactionCatalog.FACTION_SMUGGLERS: 10,
		FactionCatalog.FACTION_NAVY: 0,
		FactionCatalog.FACTION_MERCHANTS: 0,
	},
	DangerZoneCatalog.ZONE_ABYSS: {
		FactionCatalog.FACTION_ABYSS_CULT: 80,
		FactionCatalog.FACTION_PIRATES: 20,
		FactionCatalog.FACTION_NAVY: 0,
		FactionCatalog.FACTION_MERCHANTS: 0,
		FactionCatalog.FACTION_SMUGGLERS: 0,
	},
}

var _zone_controls: Dictionary = {}
var _last_change_summary: String = "Aucun changement"


func _ready() -> void:
	_initialize_zone_controls()


func get_zone_control(zone_id_or_name: String) -> Dictionary:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	_ensure_zone_control(zone_id)
	var control: Dictionary = _zone_controls[zone_id]
	return control.duplicate(true)


func get_zone_dominant_faction(zone_id_or_name: String) -> String:
	var control: Dictionary = get_zone_control(zone_id_or_name)
	return String(control.get("dominant_faction", FactionCatalog.FACTION_NAVY))


func get_faction_influence(zone_id_or_name: String, faction_id: String) -> int:
	var control: Dictionary = get_zone_control(zone_id_or_name)
	var influence: Dictionary = control.get("influence", {})
	return clampi(int(influence.get(faction_id, 0)), 0, 100)


func add_faction_influence(zone_id_or_name: String, faction_id: String, amount: int, reason: String = "") -> Dictionary:
	if amount <= 0 or not FactionCatalog.has_faction(faction_id):
		return get_zone_control(zone_id_or_name)

	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var influence: Dictionary = _get_zone_influence_copy(zone_id)
	var current_value: int = clampi(int(influence.get(faction_id, 0)), 0, 100)
	influence[faction_id] = current_value + amount
	return _set_zone_influence(zone_id, influence, faction_id, _build_reason(reason, "+%d %s" % [amount, faction_id]))


func reduce_faction_influence(zone_id_or_name: String, faction_id: String, amount: int, reason: String = "") -> Dictionary:
	if amount <= 0 or not FactionCatalog.has_faction(faction_id):
		return get_zone_control(zone_id_or_name)

	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var influence: Dictionary = _get_zone_influence_copy(zone_id)
	var current_value: int = clampi(int(influence.get(faction_id, 0)), 0, 100)
	influence[faction_id] = maxi(0, current_value - amount)
	return _set_zone_influence(zone_id, influence, "", _build_reason(reason, "-%d %s" % [amount, faction_id]))


func normalize_zone_influence(zone_id_or_name: String) -> Dictionary:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var influence: Dictionary = _get_zone_influence_copy(zone_id)
	return _set_zone_influence(zone_id, influence, "", "normalisation")


func get_pirate_spawn_multiplier(zone_id_or_name: String) -> float:
	return clampf(_get_weighted_modifier(zone_id_or_name, "pirate_spawn"), 0.55, 1.40)


func get_marine_creature_spawn_multiplier(zone_id_or_name: String) -> float:
	return clampf(_get_weighted_modifier(zone_id_or_name, "marine_spawn"), 0.65, 1.45)


func get_creature_spawn_weight_multiplier(zone_id_or_name: String, creature_id: String) -> float:
	var creature_level: int = MarineCreatureCatalog.get_creature_level(creature_id)
	if creature_level < 3:
		return 1.0

	return clampf(_get_weighted_modifier(zone_id_or_name, "dangerous_creature"), 0.70, 1.55)


func get_trade_sell_multiplier(zone_id_or_name: String) -> float:
	return clampf(_get_weighted_modifier(zone_id_or_name, "trade_sell"), 0.85, 1.15)


func get_repair_cost_multiplier(zone_id_or_name: String) -> float:
	return clampf(_get_weighted_modifier(zone_id_or_name, "repair_cost"), 0.85, 1.20)


func get_rare_reward_multiplier(zone_id_or_name: String) -> float:
	return clampf(_get_weighted_modifier(zone_id_or_name, "rare_reward"), 0.90, 1.25)


func get_zone_control_lines(zone_id_or_name: String) -> Array[String]:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var control: Dictionary = get_zone_control(zone_id)
	var influence: Dictionary = control.get("influence", {})
	var lines: Array[String] = []
	for faction_id in FactionCatalog.get_faction_ids():
		lines.append("%s : %d %%" % [
			FactionCatalog.get_faction_name(faction_id),
			clampi(int(influence.get(faction_id, 0)), 0, 100),
		])

	lines.append("Dominant : %s" % FactionCatalog.get_faction_name(String(control.get("dominant_faction", ""))))
	lines.append("Stabilite : %s" % String(control.get("stability", "moyenne")))
	lines.append("Conflit : %s" % String(control.get("conflict", "moyen")))
	return lines


func get_zone_effect_lines(zone_id_or_name: String) -> Array[String]:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var dominant_faction: String = get_zone_dominant_faction(zone_id)
	return [
		FactionCatalog.get_port_effect_text(dominant_faction),
		"Spawns pirates : x%.2f" % get_pirate_spawn_multiplier(zone_id),
		"Creatures marines : x%.2f" % get_marine_creature_spawn_multiplier(zone_id),
		"Vente commerce : x%.2f" % get_trade_sell_multiplier(zone_id),
		"Reparations : x%.2f" % get_repair_cost_multiplier(zone_id),
	]


func get_compact_zone_control_text(zone_id_or_name: String) -> String:
	var dominant_faction: String = get_zone_dominant_faction(zone_id_or_name)
	return "Controle: %s" % FactionCatalog.get_hud_label(dominant_faction)


func get_debug_summary(zone_id_or_name: String = "") -> String:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	if zone_id_or_name.is_empty():
		zone_id = DangerZoneCatalog.ZONE_SAFE

	var lines: Array[String] = [
		"Zone : %s" % DangerZoneCatalog.get_zone_name(zone_id),
		"Dernier changement : %s" % _last_change_summary,
	]
	lines.append_array(get_zone_control_lines(zone_id))
	lines.append_array(get_zone_effect_lines(zone_id))
	return "\n".join(lines)


func get_last_change_summary() -> String:
	return _last_change_summary


func print_debug_summary(zone_id_or_name: String = "") -> void:
	if not debug_territory_control:
		return

	print(get_debug_summary(zone_id_or_name))


func _initialize_zone_controls() -> void:
	_zone_controls.clear()
	for zone_id in DangerZoneCatalog.get_zone_ids():
		var influence: Dictionary = _get_initial_influence(zone_id)
		_zone_controls[zone_id] = _build_zone_control(zone_id, _normalize_influence(influence, ""))


func _ensure_zone_control(zone_id_or_name: String) -> void:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	if _zone_controls.has(zone_id):
		return

	var influence: Dictionary = _get_initial_influence(zone_id)
	_zone_controls[zone_id] = _build_zone_control(zone_id, _normalize_influence(influence, ""))


func _get_initial_influence(zone_id: String) -> Dictionary:
	if INITIAL_INFLUENCE.has(zone_id):
		var influence: Dictionary = INITIAL_INFLUENCE[zone_id]
		return influence.duplicate(true)

	var fallback: Dictionary = {}
	for faction_id in FactionCatalog.get_faction_ids():
		fallback[faction_id] = 0
	fallback[FactionCatalog.FACTION_NAVY] = 50
	fallback[FactionCatalog.FACTION_MERCHANTS] = 50
	return fallback


func _get_zone_influence_copy(zone_id_or_name: String) -> Dictionary:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var control: Dictionary = get_zone_control(zone_id)
	var influence: Dictionary = control.get("influence", {})
	return influence.duplicate(true)


func _set_zone_influence(zone_id: String, raw_influence: Dictionary, preferred_adjustment_faction: String, reason: String) -> Dictionary:
	var old_dominant: String = ""
	if _zone_controls.has(zone_id):
		var old_control: Dictionary = _zone_controls[zone_id]
		old_dominant = String(old_control.get("dominant_faction", ""))

	var influence: Dictionary = _normalize_influence(raw_influence, preferred_adjustment_faction)
	var new_control: Dictionary = _build_zone_control(zone_id, influence)
	_zone_controls[zone_id] = new_control
	_last_change_summary = "%s : %s" % [DangerZoneCatalog.get_zone_name(zone_id), reason]

	zone_control_changed.emit(zone_id, new_control.duplicate(true))

	var new_dominant: String = String(new_control.get("dominant_faction", ""))
	if not old_dominant.is_empty() and old_dominant != new_dominant:
		var message: String = FactionCatalog.get_dominance_message(new_dominant, DangerZoneCatalog.get_zone_name(zone_id))
		dominant_faction_changed.emit(zone_id, new_dominant, FactionCatalog.get_faction_name(new_dominant), message)

	_debug("changed %s -> %s | %s" % [old_dominant, new_dominant, _last_change_summary])
	print_debug_summary(zone_id)
	return new_control.duplicate(true)


func _normalize_influence(raw_influence: Dictionary, preferred_adjustment_faction: String) -> Dictionary:
	var clamped: Dictionary = {}
	var total: int = 0
	for faction_id in FactionCatalog.get_faction_ids():
		var value: int = clampi(int(raw_influence.get(faction_id, 0)), 0, MAX_INFLUENCE_TOTAL)
		clamped[faction_id] = value
		total += value

	if total <= 0:
		return _get_initial_influence(DangerZoneCatalog.ZONE_SAFE)

	var normalized: Dictionary = {}
	var normalized_total: int = 0
	for faction_id in FactionCatalog.get_faction_ids():
		var raw_value: int = int(clamped.get(faction_id, 0))
		var scaled_value: int = roundi(float(raw_value) * float(MAX_INFLUENCE_TOTAL) / float(total))
		normalized[faction_id] = clampi(scaled_value, 0, MAX_INFLUENCE_TOTAL)
		normalized_total += int(normalized[faction_id])

	var adjustment_faction: String = preferred_adjustment_faction
	if adjustment_faction.is_empty() or not FactionCatalog.has_faction(adjustment_faction):
		adjustment_faction = _get_dominant_faction_from_influence(normalized)

	normalized[adjustment_faction] = clampi(
		int(normalized.get(adjustment_faction, 0)) + (MAX_INFLUENCE_TOTAL - normalized_total),
		0,
		MAX_INFLUENCE_TOTAL
	)

	return _rebalance_to_total(normalized)


func _rebalance_to_total(influence: Dictionary) -> Dictionary:
	var normalized: Dictionary = influence.duplicate(true)
	var total: int = _get_influence_total(normalized)
	var guard: int = 0
	while total != MAX_INFLUENCE_TOTAL and guard < 100:
		guard += 1
		var dominant_faction: String = _get_dominant_faction_from_influence(normalized)
		if total < MAX_INFLUENCE_TOTAL:
			normalized[dominant_faction] = clampi(int(normalized.get(dominant_faction, 0)) + 1, 0, MAX_INFLUENCE_TOTAL)
		else:
			var reducible_faction: String = _get_highest_reducible_faction(normalized)
			if reducible_faction.is_empty():
				break
			normalized[reducible_faction] = maxi(0, int(normalized.get(reducible_faction, 0)) - 1)
		total = _get_influence_total(normalized)

	return normalized


func _build_zone_control(zone_id: String, influence: Dictionary) -> Dictionary:
	var dominant_faction: String = _get_dominant_faction_from_influence(influence)
	var top_value: int = clampi(int(influence.get(dominant_faction, 0)), 0, 100)
	var second_value: int = _get_second_highest_influence(influence, dominant_faction)
	return {
		"zone_id": zone_id,
		"zone_name": DangerZoneCatalog.get_zone_name(zone_id),
		"influence": influence.duplicate(true),
		"dominant_faction": dominant_faction,
		"dominant_faction_name": FactionCatalog.get_faction_name(dominant_faction),
		"stability": _get_stability_label(top_value),
		"conflict": _get_conflict_label(top_value, second_value),
	}


func _get_dominant_faction_from_influence(influence: Dictionary) -> String:
	var best_faction: String = FactionCatalog.FACTION_NAVY
	var best_value: int = -1
	for faction_id in FactionCatalog.get_faction_ids():
		var value: int = int(influence.get(faction_id, 0))
		if value > best_value:
			best_value = value
			best_faction = faction_id

	return best_faction


func _get_second_highest_influence(influence: Dictionary, dominant_faction: String) -> int:
	var second_value: int = 0
	for faction_id in FactionCatalog.get_faction_ids():
		if faction_id == dominant_faction:
			continue
		second_value = maxi(second_value, int(influence.get(faction_id, 0)))

	return second_value


func _get_highest_reducible_faction(influence: Dictionary) -> String:
	var best_faction: String = ""
	var best_value: int = 0
	for faction_id in FactionCatalog.get_faction_ids():
		var value: int = int(influence.get(faction_id, 0))
		if value > best_value:
			best_value = value
			best_faction = faction_id

	return best_faction


func _get_influence_total(influence: Dictionary) -> int:
	var total: int = 0
	for faction_id in FactionCatalog.get_faction_ids():
		total += clampi(int(influence.get(faction_id, 0)), 0, MAX_INFLUENCE_TOTAL)

	return total


func _get_stability_label(dominant_value: int) -> String:
	if dominant_value >= 65:
		return "haute"
	if dominant_value >= 45:
		return "moyenne"
	return "basse"


func _get_conflict_label(dominant_value: int, second_value: int) -> String:
	if dominant_value < 45 or second_value >= 25:
		return "eleve"
	if dominant_value < 65 or second_value >= 15:
		return "moyen"
	return "faible"


func _get_weighted_modifier(zone_id_or_name: String, modifier_key: String) -> float:
	var control: Dictionary = get_zone_control(zone_id_or_name)
	var influence: Dictionary = control.get("influence", {})
	var weighted_value: float = 0.0
	for faction_id in FactionCatalog.get_faction_ids():
		var share: float = clampf(float(influence.get(faction_id, 0)) / 100.0, 0.0, 1.0)
		weighted_value += share * _get_faction_modifier(faction_id, modifier_key)

	return weighted_value


func _get_faction_modifier(faction_id: String, modifier_key: String) -> float:
	match modifier_key:
		"pirate_spawn":
			return FactionCatalog.get_pirate_spawn_multiplier(faction_id)
		"marine_spawn":
			return FactionCatalog.get_marine_spawn_multiplier(faction_id)
		"dangerous_creature":
			return FactionCatalog.get_dangerous_creature_multiplier(faction_id)
		"trade_sell":
			return FactionCatalog.get_trade_sell_multiplier(faction_id)
		"repair_cost":
			return FactionCatalog.get_repair_cost_multiplier(faction_id)
		"rare_reward":
			return FactionCatalog.get_rare_reward_multiplier(faction_id)

	return 1.0


func _build_reason(reason: String, fallback: String) -> String:
	if reason.strip_edges().is_empty():
		return fallback

	return reason


func _debug(message: String) -> void:
	if not debug_territory_control:
		return

	print("TerritoryControlSystem: %s" % message)
