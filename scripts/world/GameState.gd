extends Node

signal resources_changed(gold: int, wood: int)
signal treasure_resources_changed(map_fragments: int, ancient_relics: int)
signal danger_changed(danger_level: int, enemies_defeated: int)
signal player_ship_changed(ship_id: String, ship_name: String)
signal owned_player_ships_changed(owned_ship_ids: Array[String])
signal cargo_changed(cargo_items: Dictionary, used: int, capacity: int)

const ENEMIES_PER_DANGER_LEVEL := 3
const STARTING_PLAYER_SHIP_ID := "barque"

var danger_level: int = 1
var enemies_defeated: int = 0
var gold: int = 0
var wood: int = 0
var map_fragments: int = 0
var ancient_relics: int = 0
var opened_island_chests: Dictionary = {}
var active_player_ship_id: String = STARTING_PLAYER_SHIP_ID
var owned_player_ship_ids: Array[String] = [STARTING_PLAYER_SHIP_ID]
var cargo_items: Dictionary = {}


func _ready() -> void:
	_ensure_valid_player_ship_state()
	_emit_cargo_changed()


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


func get_danger_level() -> int:
	return danger_level


func get_enemies_defeated() -> int:
	return enemies_defeated


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
		"sell_price": CargoCatalog.get_sell_price(item_id),
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

	var total_price: int = CargoCatalog.get_sell_price(item_id) * amount
	add_resources(total_price, 0)
	return "Marchandise vendue : %s x%d" % [CargoCatalog.get_good_name(item_id), amount]


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


func _get_quest_system() -> Node:
	return get_node_or_null("/root/QuestSystem")


func _ensure_valid_player_ship_state() -> void:
	if not ShipCatalog.has_ship(active_player_ship_id):
		active_player_ship_id = STARTING_PLAYER_SHIP_ID
	if not owned_player_ship_ids.has(STARTING_PLAYER_SHIP_ID):
		owned_player_ship_ids.insert(0, STARTING_PLAYER_SHIP_ID)
	if not owned_player_ship_ids.has(active_player_ship_id):
		owned_player_ship_ids.append(active_player_ship_id)


func _emit_cargo_changed() -> void:
	cargo_changed.emit(get_cargo_items(), get_cargo_used(), get_cargo_capacity())
