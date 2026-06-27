extends Node

signal resources_changed(gold: int, wood: int)

var gold: int = 0
var wood: int = 0


func add_resources(gold_amount: int, wood_amount: int) -> void:
	gold += max(0, gold_amount)
	wood += max(0, wood_amount)
	resources_changed.emit(gold, wood)


func reset_resources() -> void:
	gold = 0
	wood = 0
	resources_changed.emit(gold, wood)


func get_gold() -> int:
	return gold


func get_wood() -> int:
	return wood
