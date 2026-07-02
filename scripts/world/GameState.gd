extends Node

signal resources_changed(gold: int, wood: int)
signal treasure_resources_changed(map_fragments: int, ancient_relics: int)
signal danger_changed(danger_level: int, enemies_defeated: int)
signal current_danger_zone_changed(zone_id: String, zone_name: String, zone_level: int)
signal player_ship_changed(ship_id: String, ship_name: String)
signal owned_player_ships_changed(owned_ship_ids: Array[String])
signal cargo_changed(cargo_items: Dictionary, used: int, capacity: int)
signal exploration_progress_changed(discovered_treasures: int, explored_sites: int)
signal creature_resources_changed(resources: Dictionary, creatures_defeated: int)
signal territory_control_changed(zone_id: String, control: Dictionary)
signal territory_dominant_faction_changed(zone_id: String, faction_id: String, faction_name: String, message: String)
signal player_faction_changed(faction_id: String, faction_name: String, bonus_summary: String)

const ENEMIES_PER_DANGER_LEVEL := 3
const STARTING_PLAYER_SHIP_ID := "barque"

@export var debug_player_faction: bool = false

var danger_level: int = 1
var current_danger_zone_id: String = DangerZoneCatalog.ZONE_SAFE
var enemies_defeated: int = 0
var gold: int = 0
var wood: int = 0
var map_fragments: int = 0
var ancient_relics: int = 0
var opened_island_chests: Dictionary = {}
var explored_exploration_sites: Dictionary = {}
var discovered_treasures: Dictionary = {}
var creature_resources: Dictionary = {}
var marine_creatures_defeated: int = 0
var active_player_ship_id: String = STARTING_PLAYER_SHIP_ID
var owned_player_ship_ids: Array[String] = [STARTING_PLAYER_SHIP_ID]
var cargo_items: Dictionary = {}
var player_faction_id: String = FactionCatalog.FACTION_NEUTRAL
var player_faction_locked: bool = false
var _last_player_faction_change: String = "Neutre"
var _last_player_faction_territory_bonus: String = "Aucun"


func _ready() -> void:
	_ensure_valid_player_ship_state()
	_ensure_valid_player_faction_state()
	_emit_cargo_changed()
	_emit_current_danger_zone_changed()
	_emit_creature_resources_changed()
	_emit_player_faction_changed()
	call_deferred("_connect_territory_control_system")


func add_resources(gold_amount: int, wood_amount: int) -> void:
	gold += max(0, gold_amount)
	wood += max(0, wood_amount)
	resources_changed.emit(gold, wood)


func add_treasure_resources(map_fragment_amount: int, ancient_relic_amount: int, track_quests: bool = false) -> void:
	map_fragments += max(0, map_fragment_amount)
	ancient_relics += max(0, ancient_relic_amount)
	treasure_resources_changed.emit(map_fragments, ancient_relics)
	if not track_quests:
		return

	var quest_system := _get_quest_system()
	if quest_system != null and quest_system.has_method("record_treasure_resources_gained"):
		quest_system.record_treasure_resources_gained(map_fragment_amount, ancient_relic_amount)


func can_afford(gold_cost: int, wood_cost: int) -> bool:
	return gold >= gold_cost and wood >= wood_cost


func can_afford_cost(cost: Dictionary) -> bool:
	return (
		gold >= int(cost.get("gold", 0))
		and wood >= int(cost.get("wood", 0))
		and map_fragments >= int(cost.get("map_fragments", 0))
		and ancient_relics >= int(cost.get("ancient_relics", 0))
	)


func spend_resources(gold_cost: int, wood_cost: int) -> bool:
	gold_cost = max(0, gold_cost)
	wood_cost = max(0, wood_cost)

	if not can_afford(gold_cost, wood_cost):
		return false

	gold -= gold_cost
	wood -= wood_cost
	resources_changed.emit(gold, wood)
	return true


func spend_cost(cost: Dictionary) -> bool:
	if not can_afford_cost(cost):
		return false

	var gold_cost: int = maxi(0, int(cost.get("gold", 0)))
	var wood_cost: int = maxi(0, int(cost.get("wood", 0)))
	var fragment_cost: int = maxi(0, int(cost.get("map_fragments", 0)))
	var relic_cost: int = maxi(0, int(cost.get("ancient_relics", 0)))

	gold -= gold_cost
	wood -= wood_cost
	map_fragments -= fragment_cost
	ancient_relics -= relic_cost

	if gold_cost > 0 or wood_cost > 0:
		resources_changed.emit(gold, wood)
	if fragment_cost > 0 or relic_cost > 0:
		treasure_resources_changed.emit(map_fragments, ancient_relics)

	return true


func reset_resources() -> void:
	gold = 0
	wood = 0
	map_fragments = 0
	ancient_relics = 0
	resources_changed.emit(gold, wood)
	treasure_resources_changed.emit(map_fragments, ancient_relics)


func record_enemy_destroyed() -> void:
	enemies_defeated += 1
	danger_level = 1 + int(enemies_defeated / ENEMIES_PER_DANGER_LEVEL)
	danger_changed.emit(danger_level, enemies_defeated)
	_record_enemy_destroyed_territory_change()
	var quest_system := _get_quest_system()
	if quest_system != null and quest_system.has_method("record_enemy_destroyed"):
		quest_system.record_enemy_destroyed()


func is_island_chest_opened(chest_id: String) -> bool:
	if chest_id.is_empty():
		return false

	return bool(opened_island_chests.get(chest_id, false))


func mark_island_chest_opened(chest_id: String) -> void:
	if chest_id.is_empty():
		return

	opened_island_chests[chest_id] = true


func reset_island_chests() -> void:
	opened_island_chests.clear()


func is_exploration_site_explored(site_id: String) -> bool:
	if site_id.is_empty():
		return false

	return bool(explored_exploration_sites.get(site_id, false))


func mark_exploration_site_explored(site_id: String, treasure_id: String = "", zone_id_or_name: String = "") -> bool:
	if site_id.is_empty():
		return false
	if bool(explored_exploration_sites.get(site_id, false)):
		return false

	explored_exploration_sites[site_id] = true
	if not treasure_id.is_empty():
		var current_count: int = maxi(0, int(discovered_treasures.get(treasure_id, 0)))
		discovered_treasures[treasure_id] = current_count + 1

	exploration_progress_changed.emit(get_discovered_treasure_count(), get_explored_site_count())
	_record_exploration_territory_change(zone_id_or_name, treasure_id)
	return true


func reset_exploration_sites() -> void:
	explored_exploration_sites.clear()
	discovered_treasures.clear()
	exploration_progress_changed.emit(0, 0)


func record_marine_creature_defeated(creature_id: String) -> void:
	marine_creatures_defeated += 1
	_record_marine_creature_territory_change(creature_id)
	_emit_creature_resources_changed()


func add_creature_resource(resource_id: String, amount: int) -> void:
	if resource_id.is_empty() or amount <= 0:
		return

	var current_amount: int = maxi(0, int(creature_resources.get(resource_id, 0)))
	creature_resources[resource_id] = current_amount + amount
	_apply_player_faction_territory_bonus(get_current_danger_zone_id_safe(), "rare_creature_resource")
	_emit_creature_resources_changed()


func get_creature_resource_amount(resource_id: String) -> int:
	return maxi(0, int(creature_resources.get(resource_id, 0)))


func get_creature_resources() -> Dictionary:
	return creature_resources.duplicate(true)


func get_creature_resources_view() -> Array[Dictionary]:
	var resources: Array[Dictionary] = []
	for resource_id in creature_resources.keys():
		var resource_key: String = String(resource_id)
		var amount: int = get_creature_resource_amount(resource_key)
		if amount <= 0:
			continue

		resources.append({
			"id": resource_key,
			"name": MarineCreatureCatalog.get_resource_name(resource_key),
			"amount": amount,
		})

	return resources


func get_marine_creatures_defeated() -> int:
	return marine_creatures_defeated


func get_explored_site_count() -> int:
	return explored_exploration_sites.size()


func get_discovered_treasure_count() -> int:
	var count: int = 0
	for treasure_id in discovered_treasures.keys():
		count += maxi(0, int(discovered_treasures.get(treasure_id, 0)))

	return count


func get_discovered_treasure_types_count() -> int:
	return discovered_treasures.size()


func get_danger_level() -> int:
	return danger_level


func get_enemies_defeated() -> int:
	return enemies_defeated


func set_current_danger_zone(zone_id_or_name: String) -> bool:
	var normalized_zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	if normalized_zone_id == current_danger_zone_id:
		return false

	current_danger_zone_id = normalized_zone_id
	_emit_current_danger_zone_changed()
	_emit_current_territory_control_changed()
	return true


func get_current_danger_zone_id() -> String:
	return current_danger_zone_id


func get_current_danger_zone_id_safe() -> String:
	var normalized_zone_id: String = DangerZoneCatalog.normalize_zone_id(current_danger_zone_id)
	if normalized_zone_id.is_empty():
		return DangerZoneCatalog.ZONE_SAFE

	return normalized_zone_id


func get_current_danger_zone_name() -> String:
	return DangerZoneCatalog.get_zone_name(current_danger_zone_id)


func get_current_danger_zone_level() -> int:
	return DangerZoneCatalog.get_zone_level(current_danger_zone_id)


func get_current_danger_reward_multiplier() -> float:
	return DangerZoneCatalog.get_reward_multiplier(current_danger_zone_id)


func get_player_faction_id() -> String:
	_ensure_valid_player_faction_state()
	return player_faction_id


func get_player_faction_name() -> String:
	return FactionCatalog.get_player_faction_name(get_player_faction_id())


func is_player_neutral() -> bool:
	return get_player_faction_id() == FactionCatalog.FACTION_NEUTRAL


func is_player_faction_locked() -> bool:
	_ensure_valid_player_faction_state()
	return player_faction_locked


func can_join_faction(faction_id: String) -> bool:
	return FactionCatalog.has_player_faction(faction_id)


func can_choose_player_faction(faction_id: String) -> bool:
	if is_player_faction_locked():
		return false
	if not FactionCatalog.has_player_faction(faction_id):
		return false

	var normalized_faction_id: String = FactionCatalog.normalize_player_faction_id(faction_id)
	return normalized_faction_id != FactionCatalog.FACTION_NEUTRAL


func is_player_faction_valid() -> bool:
	return FactionCatalog.has_player_faction(player_faction_id)


func set_player_faction(faction_id: String) -> String:
	if not FactionCatalog.has_player_faction(faction_id):
		return "Faction inconnue - choix refuse"

	if is_player_faction_locked():
		return get_player_faction_lock_message()

	var normalized_faction_id: String = FactionCatalog.normalize_player_faction_id(faction_id)
	if normalized_faction_id == player_faction_id:
		return "Allegeance actuelle : %s" % get_player_faction_name()
	if normalized_faction_id != FactionCatalog.FACTION_NEUTRAL:
		return lock_player_faction(normalized_faction_id)

	player_faction_id = normalized_faction_id
	player_faction_locked = false
	_last_player_faction_change = FactionCatalog.get_player_faction_name(player_faction_id)
	_emit_player_faction_changed()
	_debug_player_faction("allegeance -> %s" % _last_player_faction_change)
	return FactionCatalog.get_player_join_message(player_faction_id)


func lock_player_faction(faction_id: String) -> String:
	if not FactionCatalog.has_player_faction(faction_id):
		return "Faction inconnue - choix refuse"

	var normalized_faction_id: String = FactionCatalog.normalize_player_faction_id(faction_id)
	if normalized_faction_id == FactionCatalog.FACTION_NEUTRAL:
		return "Neutre est l'etat de depart. Choisissez une vraie voie pour verrouiller la partie."
	if is_player_faction_locked():
		return get_player_faction_lock_message()

	player_faction_id = normalized_faction_id
	player_faction_locked = true
	_last_player_faction_change = "Voie definitive : %s" % get_player_faction_name()
	_emit_player_faction_changed()
	_debug_player_faction("voie verrouillee -> %s" % get_player_faction_name())
	return "%s\nVotre allegeance est desormais definitive" % _get_player_faction_path_message(player_faction_id)


func get_player_faction_lock_message() -> String:
	if is_player_faction_locked():
		return "Allegeance verrouillee : %s\nCette voie est definitive pour cette partie.\nCommencez une nouvelle partie pour choisir une autre voie." % get_player_faction_name()

	return "Choisissez une voie.\nCe choix est definitif pour cette partie.\nPour jouer une autre faction, il faudra commencer une nouvelle partie."


func get_player_faction_lock_status() -> String:
	if is_player_faction_locked():
		return "Definitif pour cette partie"

	return "choix non effectue"


func get_player_faction_bonus_summary() -> String:
	return FactionCatalog.get_player_bonus_summary(_get_active_player_faction_id())


func get_player_ship_combat_gold_multiplier() -> float:
	return FactionCatalog.get_player_bonus_modifier(_get_active_player_faction_id(), "ship_combat_gold_multiplier", 1.0)


func get_player_pirate_renown_multiplier() -> float:
	return FactionCatalog.get_player_bonus_modifier(_get_active_player_faction_id(), "pirate_renown_multiplier", 1.0)


func get_player_trade_profit_multiplier() -> float:
	return FactionCatalog.get_player_bonus_modifier(_get_active_player_faction_id(), "trade_profit_multiplier", 1.0)


func get_player_rare_creature_resource_multiplier() -> float:
	return FactionCatalog.get_player_bonus_modifier(_get_active_player_faction_id(), "rare_creature_resource_multiplier", 1.0)


func get_player_dangerous_creature_reward_multiplier() -> float:
	return FactionCatalog.get_player_bonus_modifier(_get_active_player_faction_id(), "dangerous_creature_reward_multiplier", 1.0)


func get_player_territory_bonus_faction() -> String:
	return FactionCatalog.get_player_territory_bonus_faction(_get_active_player_faction_id())


func get_player_territory_bonus_amount() -> int:
	return FactionCatalog.get_player_territory_bonus_amount(_get_active_player_faction_id())


func get_player_faction_debug_summary() -> String:
	return "Faction joueur : %s\nStatut : %s\nBonus : %s\nDernier choix : %s\nDernier effet territoire : %s" % [
		get_player_faction_name(),
		get_player_faction_lock_status(),
		get_player_faction_bonus_summary(),
		_last_player_faction_change,
		_last_player_faction_territory_bonus,
	]


func print_player_faction_debug() -> void:
	if not debug_player_faction:
		return

	print(get_player_faction_debug_summary())


func get_zone_control(zone_id_or_name: String) -> Dictionary:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_zone_control"):
		var control_value: Variant = territory_system.call("get_zone_control", zone_id_or_name)
		if control_value is Dictionary:
			var control: Dictionary = control_value
			return control.duplicate(true)

	return {}


func get_current_zone_control() -> Dictionary:
	return get_zone_control(current_danger_zone_id)


func get_zone_dominant_faction(zone_id_or_name: String) -> String:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_zone_dominant_faction"):
		return String(territory_system.call("get_zone_dominant_faction", zone_id_or_name))

	return FactionCatalog.FACTION_NAVY


func get_current_zone_dominant_faction() -> String:
	return get_zone_dominant_faction(current_danger_zone_id)


func get_faction_influence(zone_id_or_name: String, faction_id: String) -> int:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_faction_influence"):
		return clampi(int(territory_system.call("get_faction_influence", zone_id_or_name, faction_id)), 0, 100)

	return 0


func add_faction_influence(zone_id_or_name: String, faction_id: String, amount: int, reason: String = "") -> Dictionary:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("add_faction_influence"):
		var control_value: Variant = territory_system.call("add_faction_influence", zone_id_or_name, faction_id, amount, reason)
		if control_value is Dictionary:
			var control: Dictionary = control_value
			return control.duplicate(true)

	return get_zone_control(zone_id_or_name)


func reduce_faction_influence(zone_id_or_name: String, faction_id: String, amount: int, reason: String = "") -> Dictionary:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("reduce_faction_influence"):
		var control_value: Variant = territory_system.call("reduce_faction_influence", zone_id_or_name, faction_id, amount, reason)
		if control_value is Dictionary:
			var control: Dictionary = control_value
			return control.duplicate(true)

	return get_zone_control(zone_id_or_name)


func normalize_zone_influence(zone_id_or_name: String) -> Dictionary:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("normalize_zone_influence"):
		var control_value: Variant = territory_system.call("normalize_zone_influence", zone_id_or_name)
		if control_value is Dictionary:
			var control: Dictionary = control_value
			return control.duplicate(true)

	return get_zone_control(zone_id_or_name)


func get_zone_control_lines(zone_id_or_name: String) -> Array[String]:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_zone_control_lines"):
		var raw_lines: Variant = territory_system.call("get_zone_control_lines", zone_id_or_name)
		if raw_lines is Array:
			var lines: Array[String] = []
			for raw_line in raw_lines:
				lines.append(String(raw_line))
			return lines

	return []


func get_zone_effect_lines(zone_id_or_name: String) -> Array[String]:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_zone_effect_lines"):
		var raw_lines: Variant = territory_system.call("get_zone_effect_lines", zone_id_or_name)
		if raw_lines is Array:
			var lines: Array[String] = []
			for raw_line in raw_lines:
				lines.append(String(raw_line))
			return lines

	return []


func get_current_zone_control_lines() -> Array[String]:
	return get_zone_control_lines(current_danger_zone_id)


func get_current_zone_effect_lines() -> Array[String]:
	return get_zone_effect_lines(current_danger_zone_id)


func get_compact_zone_control_text(zone_id_or_name: String) -> String:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_compact_zone_control_text"):
		return String(territory_system.call("get_compact_zone_control_text", zone_id_or_name))

	return "Controle: %s" % FactionCatalog.get_hud_label(get_zone_dominant_faction(zone_id_or_name))


func get_pirate_spawn_multiplier(zone_id_or_name: String) -> float:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_pirate_spawn_multiplier"):
		return clampf(float(territory_system.call("get_pirate_spawn_multiplier", zone_id_or_name)), 0.55, 1.40)

	return 1.0


func get_marine_creature_spawn_multiplier(zone_id_or_name: String) -> float:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_marine_creature_spawn_multiplier"):
		return clampf(float(territory_system.call("get_marine_creature_spawn_multiplier", zone_id_or_name)), 0.65, 1.45)

	return 1.0


func get_creature_spawn_weight_multiplier(zone_id_or_name: String, creature_id: String) -> float:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_creature_spawn_weight_multiplier"):
		return clampf(float(territory_system.call("get_creature_spawn_weight_multiplier", zone_id_or_name, creature_id)), 0.70, 1.55)

	return 1.0


func get_trade_sell_multiplier(zone_id_or_name: String) -> float:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_trade_sell_multiplier"):
		return clampf(float(territory_system.call("get_trade_sell_multiplier", zone_id_or_name)), 0.85, 1.15)

	return 1.0


func get_repair_cost_multiplier(zone_id_or_name: String) -> float:
	var territory_system: Node = _get_territory_control_system()
	if territory_system != null and territory_system.has_method("get_repair_cost_multiplier"):
		return clampf(float(territory_system.call("get_repair_cost_multiplier", zone_id_or_name)), 0.85, 1.20)

	return 1.0


func get_gold() -> int:
	return gold


func get_wood() -> int:
	return wood


func get_map_fragments() -> int:
	return map_fragments


func get_ancient_relics() -> int:
	return ancient_relics


func get_active_player_ship_id() -> String:
	_ensure_valid_player_ship_state()
	return active_player_ship_id


func get_active_player_ship_name() -> String:
	return ShipCatalog.get_ship_name(get_active_player_ship_id())


func get_active_player_ship_data() -> Dictionary:
	return ShipCatalog.get_ship(get_active_player_ship_id())


func get_player_storage_capacity() -> int:
	var ship: Dictionary = get_active_player_ship_data()
	return int(ship.get("storage", 0))


func get_player_ship_cargo_capacity(ship_id: String) -> int:
	if not ShipCatalog.has_ship(ship_id):
		return 0

	var ship: Dictionary = ShipCatalog.get_ship(ship_id)
	return maxi(0, int(ship.get("storage", 0)))


func get_cargo_capacity() -> int:
	return get_player_storage_capacity()


func get_cargo_used() -> int:
	var used: int = 0
	for item_id in cargo_items.keys():
		var item_key: String = String(item_id)
		if not CargoCatalog.has_good(item_key):
			continue

		var quantity: int = maxi(0, int(cargo_items.get(item_key, 0)))
		used += CargoCatalog.get_good_weight(item_key) * quantity

	return used


func get_cargo_free() -> int:
	return maxi(0, get_cargo_capacity() - get_cargo_used())


func get_cargo_quantity(item_id: String) -> int:
	return maxi(0, int(cargo_items.get(item_id, 0)))


func can_add_cargo(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	if not CargoCatalog.has_good(item_id):
		return false

	var added_weight: int = CargoCatalog.get_good_weight(item_id) * amount
	return added_weight <= get_cargo_free()


func add_cargo(item_id: String, amount: int) -> bool:
	if not can_add_cargo(item_id, amount):
		return false

	cargo_items[item_id] = get_cargo_quantity(item_id) + amount
	_emit_cargo_changed()
	return true


func remove_cargo(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	if not CargoCatalog.has_good(item_id):
		return false
	if get_cargo_quantity(item_id) < amount:
		return false

	var new_quantity: int = get_cargo_quantity(item_id) - amount
	if new_quantity <= 0:
		cargo_items.erase(item_id)
	else:
		cargo_items[item_id] = new_quantity

	_emit_cargo_changed()
	return true


func get_cargo_items() -> Dictionary:
	return cargo_items.duplicate(true)


func get_trade_good_view(item_id: String) -> Dictionary:
	if not CargoCatalog.has_good(item_id):
		return {}

	var quantity: int = get_cargo_quantity(item_id)
	var weight: int = CargoCatalog.get_good_weight(item_id)
	return {
		"id": item_id,
		"name": CargoCatalog.get_good_name(item_id),
		"weight": weight,
		"buy_price": CargoCatalog.get_buy_price(item_id),
		"sell_price": _get_trade_sell_price(item_id),
		"quantity": quantity,
		"used_space": quantity * weight,
		"can_buy": can_buy_trade_good(item_id, 1),
		"can_sell": can_sell_trade_good(item_id, 1),
	}


func get_trade_good_views() -> Array[Dictionary]:
	var views: Array[Dictionary] = []
	var good_ids: Array[String] = CargoCatalog.get_trade_good_ids()
	for item_id in good_ids:
		views.append(get_trade_good_view(item_id))

	return views


func can_buy_trade_good(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	if not CargoCatalog.has_good(item_id):
		return false

	var total_price: int = CargoCatalog.get_buy_price(item_id) * amount
	return gold >= total_price and can_add_cargo(item_id, amount)


func buy_trade_good(item_id: String, amount: int = 1) -> String:
	if amount <= 0 or not CargoCatalog.has_good(item_id):
		return "Marchandise indisponible"

	var total_price: int = CargoCatalog.get_buy_price(item_id) * amount
	if gold < total_price:
		return "Or insuffisant"
	if not can_add_cargo(item_id, amount):
		if get_cargo_free() <= 0:
			return "Cargaison pleine"
		return "Espace insuffisant"

	if not spend_resources(total_price, 0):
		return "Or insuffisant"
	if not add_cargo(item_id, amount):
		add_resources(total_price, 0)
		return "Espace insuffisant"

	return "Marchandise achetee : %s x%d" % [CargoCatalog.get_good_name(item_id), amount]


func can_sell_trade_good(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	if not CargoCatalog.has_good(item_id):
		return false

	return get_cargo_quantity(item_id) >= amount


func sell_trade_good(item_id: String, amount: int = 1) -> String:
	if amount <= 0 or not CargoCatalog.has_good(item_id):
		return "Marchandise indisponible"
	if not can_sell_trade_good(item_id, amount):
		return "Aucune marchandise a vendre"

	if not remove_cargo(item_id, amount):
		return "Aucune marchandise a vendre"

	var total_price: int = _get_trade_sell_price(item_id) * amount
	add_resources(total_price, 0)
	return "Marchandise vendue : %s x%d" % [CargoCatalog.get_good_name(item_id), amount]


func _get_trade_sell_price(item_id: String) -> int:
	if not CargoCatalog.has_good(item_id):
		return 0

	var base_price: int = CargoCatalog.get_sell_price(item_id)
	return maxi(0, roundi(float(base_price) * get_player_trade_profit_multiplier()))


func record_trade_completed(zone_id_or_name: String, amount: int = 1) -> void:
	var influence_amount: int = clampi(amount, 1, 2)
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	add_faction_influence(
		zone_id,
		FactionCatalog.FACTION_MERCHANTS,
		influence_amount,
		"commerce au port"
	)
	reduce_faction_influence(
		zone_id,
		FactionCatalog.FACTION_PIRATES,
		1,
		"routes marchandes securisees"
	)
	_apply_player_faction_territory_bonus(zone_id, "trade_completed")


func get_owned_player_ship_ids() -> Array[String]:
	_ensure_valid_player_ship_state()
	return owned_player_ship_ids.duplicate()


func is_player_ship_owned(ship_id: String) -> bool:
	return owned_player_ship_ids.has(ship_id)


func can_afford_player_ship(ship_id: String) -> bool:
	if not ShipCatalog.has_ship(ship_id):
		return false
	if is_player_ship_owned(ship_id):
		return true

	return can_afford_cost(ShipCatalog.get_ship_cost(ship_id))


func can_equip_player_ship(ship_id: String) -> bool:
	return get_ship_equip_block_reason(ship_id).is_empty()


func get_ship_equip_block_reason(ship_id: String) -> String:
	if not ShipCatalog.has_ship(ship_id):
		return "Navire indisponible"
	if not is_player_ship_owned(ship_id):
		return "Navire non possede"

	var cargo_used: int = get_cargo_used()
	var ship_capacity: int = get_player_ship_cargo_capacity(ship_id)
	if cargo_used > ship_capacity:
		return "Cargaison trop lourde pour ce navire - Cargaison : %d/%d" % [
			cargo_used,
			ship_capacity,
		]

	return ""


func purchase_player_ship(ship_id: String) -> String:
	if not ShipCatalog.has_ship(ship_id):
		return "Navire indisponible"
	if is_player_ship_owned(ship_id):
		return equip_player_ship(ship_id)

	var cost := ShipCatalog.get_ship_cost(ship_id)
	if not spend_cost(cost):
		return "Ressources insuffisantes - coût : %s" % ShipCatalog.format_cost(ship_id)

	owned_player_ship_ids.append(ship_id)
	owned_player_ships_changed.emit(get_owned_player_ship_ids())
	return "%s acheté" % ShipCatalog.get_ship_name(ship_id)


func equip_player_ship(ship_id: String) -> String:
	if not ShipCatalog.has_ship(ship_id):
		return "Navire indisponible"
	if not is_player_ship_owned(ship_id):
		return "Navire non possédé"
	if active_player_ship_id == ship_id:
		return "Navire actuel : %s" % ShipCatalog.get_ship_name(ship_id)

	var block_reason: String = get_ship_equip_block_reason(ship_id)
	if not block_reason.is_empty():
		return block_reason

	active_player_ship_id = ship_id
	player_ship_changed.emit(active_player_ship_id, get_active_player_ship_name())
	_emit_cargo_changed()
	return "%s équipé" % get_active_player_ship_name()


func _record_enemy_destroyed_territory_change() -> void:
	var zone_id: String = get_current_danger_zone_id_safe()
	reduce_faction_influence(zone_id, FactionCatalog.FACTION_PIRATES, 2, "pirate detruit")
	add_faction_influence(zone_id, FactionCatalog.FACTION_NAVY, 1, "pirate detruit")
	add_faction_influence(zone_id, FactionCatalog.FACTION_MERCHANTS, 1, "route securisee")
	_apply_player_faction_territory_bonus(zone_id, "enemy_destroyed")


func _record_marine_creature_territory_change(creature_id: String) -> void:
	var creature_level: int = 1
	if not creature_id.is_empty() and MarineCreatureCatalog.has_creature(creature_id):
		creature_level = MarineCreatureCatalog.get_creature_level(creature_id)
	if creature_level < 2:
		return

	var zone_id: String = get_current_danger_zone_id_safe()
	var abyss_reduction: int = 2
	if creature_level >= 5:
		abyss_reduction = 3

	reduce_faction_influence(zone_id, FactionCatalog.FACTION_ABYSS_CULT, abyss_reduction, "creature marine vaincue")
	add_faction_influence(zone_id, FactionCatalog.FACTION_NAVY, 1, "routes maritimes protegees")
	if creature_level >= 4:
		add_faction_influence(zone_id, FactionCatalog.FACTION_MERCHANTS, 1, "commerce rassure")


func _record_exploration_territory_change(zone_id_or_name: String, treasure_id: String) -> void:
	var zone_id: String = get_current_danger_zone_id_safe()
	if not zone_id_or_name.strip_edges().is_empty():
		zone_id = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)

	var zone_level: int = DangerZoneCatalog.get_zone_level(zone_id)
	if zone_level >= 5:
		reduce_faction_influence(zone_id, FactionCatalog.FACTION_ABYSS_CULT, 2, "tresor explore")
		add_faction_influence(zone_id, FactionCatalog.FACTION_SMUGGLERS, 1, "rumeurs de tresor")
		_apply_player_faction_territory_bonus(zone_id, "exploration")
		return

	if not treasure_id.is_empty() and TreasureCatalog.get_required_ancient_relics(treasure_id) > 0:
		reduce_faction_influence(zone_id, FactionCatalog.FACTION_ABYSS_CULT, 1, "relique recuperee")
		add_faction_influence(zone_id, FactionCatalog.FACTION_MERCHANTS, 1, "decouverte revendable")
		_apply_player_faction_territory_bonus(zone_id, "exploration")
		return

	reduce_faction_influence(zone_id, FactionCatalog.FACTION_PIRATES, 1, "site explore")
	add_faction_influence(zone_id, FactionCatalog.FACTION_MERCHANTS, 1, "cartographie utile")
	_apply_player_faction_territory_bonus(zone_id, "exploration")


func _apply_player_faction_territory_bonus(zone_id_or_name: String, action_id: String) -> void:
	if not is_player_faction_locked():
		return

	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var player_faction: String = get_player_faction_id()
	match player_faction:
		FactionCatalog.FACTION_PIRATES:
			if action_id == "exploration":
				add_faction_influence(zone_id, FactionCatalog.FACTION_PIRATES, 1, "allegeance pirate")
				_record_player_faction_territory_debug(zone_id, action_id, FactionCatalog.FACTION_PIRATES)
		FactionCatalog.FACTION_NAVY:
			if action_id == "enemy_destroyed":
				reduce_faction_influence(zone_id, FactionCatalog.FACTION_PIRATES, 1, "serment marine")
				add_faction_influence(zone_id, FactionCatalog.FACTION_NAVY, 1, "serment marine")
				_record_player_faction_territory_debug(zone_id, action_id, FactionCatalog.FACTION_NAVY)
		FactionCatalog.FACTION_MERCHANTS:
			if action_id == "trade_completed":
				add_faction_influence(zone_id, FactionCatalog.FACTION_MERCHANTS, 1, "allegeance marchande")
				_record_player_faction_territory_debug(zone_id, action_id, FactionCatalog.FACTION_MERCHANTS)
		FactionCatalog.FACTION_SMUGGLERS:
			if action_id == "rare_creature_resource" or action_id == "exploration":
				add_faction_influence(zone_id, FactionCatalog.FACTION_SMUGGLERS, 1, "reseau contrebandier")
				_record_player_faction_territory_debug(zone_id, action_id, FactionCatalog.FACTION_SMUGGLERS)


func _record_player_faction_territory_debug(zone_id: String, action_id: String, faction_id: String) -> void:
	_last_player_faction_territory_bonus = "%s : +1 %s via %s" % [
		DangerZoneCatalog.get_zone_name(zone_id),
		FactionCatalog.get_player_faction_name(faction_id),
		action_id,
	]
	_debug_player_faction(_last_player_faction_territory_bonus)


func _get_quest_system() -> Node:
	return get_node_or_null("/root/QuestSystem")


func _get_territory_control_system() -> Node:
	return get_node_or_null("/root/TerritoryControlSystem")


func _connect_territory_control_system() -> void:
	var territory_system: Node = _get_territory_control_system()
	if territory_system == null:
		return

	var control_callback: Callable = Callable(self, "_on_territory_zone_control_changed")
	if territory_system.has_signal("zone_control_changed") and not territory_system.is_connected("zone_control_changed", control_callback):
		territory_system.connect("zone_control_changed", control_callback)

	var dominant_callback: Callable = Callable(self, "_on_territory_dominant_faction_changed")
	if territory_system.has_signal("dominant_faction_changed") and not territory_system.is_connected("dominant_faction_changed", dominant_callback):
		territory_system.connect("dominant_faction_changed", dominant_callback)

	_emit_current_territory_control_changed()


func _on_territory_zone_control_changed(zone_id: String, control: Dictionary) -> void:
	territory_control_changed.emit(zone_id, control.duplicate(true))


func _on_territory_dominant_faction_changed(zone_id: String, faction_id: String, faction_name: String, message: String) -> void:
	territory_dominant_faction_changed.emit(zone_id, faction_id, faction_name, message)


func _emit_current_territory_control_changed() -> void:
	var control: Dictionary = get_zone_control(current_danger_zone_id)
	if control.is_empty():
		return

	territory_control_changed.emit(current_danger_zone_id, control)


func _ensure_valid_player_ship_state() -> void:
	if not ShipCatalog.has_ship(active_player_ship_id):
		active_player_ship_id = STARTING_PLAYER_SHIP_ID
	if not owned_player_ship_ids.has(STARTING_PLAYER_SHIP_ID):
		owned_player_ship_ids.insert(0, STARTING_PLAYER_SHIP_ID)
	if not owned_player_ship_ids.has(active_player_ship_id):
		owned_player_ship_ids.append(active_player_ship_id)


func _ensure_valid_player_faction_state() -> void:
	if not FactionCatalog.has_player_faction(player_faction_id):
		player_faction_id = FactionCatalog.FACTION_NEUTRAL
		player_faction_locked = false
		return

	if player_faction_id == FactionCatalog.FACTION_NEUTRAL:
		player_faction_locked = false
		return

	if not player_faction_locked:
		player_faction_locked = true


func _emit_player_faction_changed() -> void:
	player_faction_changed.emit(
		get_player_faction_id(),
		get_player_faction_name(),
		get_player_faction_bonus_summary()
	)


func _debug_player_faction(message: String) -> void:
	if not debug_player_faction:
		return

	print("PlayerFaction: %s" % message)


func _get_active_player_faction_id() -> String:
	if not is_player_faction_locked():
		return FactionCatalog.FACTION_NEUTRAL

	return get_player_faction_id()


func _get_player_faction_path_message(faction_id: String) -> String:
	match FactionCatalog.normalize_player_faction_id(faction_id):
		FactionCatalog.FACTION_PIRATES:
			return "Vous avez choisi la voie des Pirates"
		FactionCatalog.FACTION_NAVY:
			return "Cette partie suivra la voie de la Marine royale"
		FactionCatalog.FACTION_MERCHANTS:
			return "Cette partie suivra la voie de la Ligue marchande"
		FactionCatalog.FACTION_SMUGGLERS:
			return "Cette partie suivra la voie des Contrebandiers"
		FactionCatalog.FACTION_ABYSS_CULT:
			return "Cette partie suivra la voie des Cultes abyssaux"

	return "Allegeance mise a jour"


func _emit_cargo_changed() -> void:
	cargo_changed.emit(get_cargo_items(), get_cargo_used(), get_cargo_capacity())


func _emit_current_danger_zone_changed() -> void:
	current_danger_zone_changed.emit(
		current_danger_zone_id,
		get_current_danger_zone_name(),
		get_current_danger_zone_level()
	)


func _emit_creature_resources_changed() -> void:
	creature_resources_changed.emit(get_creature_resources(), marine_creatures_defeated)
