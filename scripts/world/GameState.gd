extends Node

signal resources_changed(gold: int, wood: int)

var gold: int = 0
var wood: int = 0


func add_resources(gold_amount: int, wood_amount: int) -> void:
	gold += max(0, gold_amount)
	wood += max(0, wood_amount)
	resources_changed.emit(gold, wood)


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
	resources_changed.emit(gold, wood)


func get_gold() -> int:
	return gold


func get_wood() -> int:
	return wood
