extends Node

signal resources_changed(gold: int, wood: int)
signal treasure_resources_changed(map_fragments: int, ancient_relics: int)
signal danger_changed(danger_level: int, enemies_defeated: int)

const ENEMIES_PER_DANGER_LEVEL := 3

var danger_level: int = 1
var enemies_defeated: int = 0
var gold: int = 0
var wood: int = 0
var map_fragments: int = 0
var ancient_relics: int = 0
var opened_island_chests: Dictionary = {}


func add_resources(gold_amount: int, wood_amount: int) -> void:
	gold += max(0, gold_amount)
	wood += max(0, wood_amount)
	resources_changed.emit(gold, wood)


func add_treasure_resources(map_fragment_amount: int, ancient_relic_amount: int, track_quests: bool = true) -> void:
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


func spend_resources(gold_cost: int, wood_cost: int) -> bool:
	gold_cost = max(0, gold_cost)
	wood_cost = max(0, wood_cost)

	if not can_afford(gold_cost, wood_cost):
		return false

	gold -= gold_cost
	wood -= wood_cost
	resources_changed.emit(gold, wood)
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


func _get_quest_system() -> Node:
	return get_node_or_null("/root/QuestSystem")
