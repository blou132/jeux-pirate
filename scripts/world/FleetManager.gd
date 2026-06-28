class_name FleetManager
extends Node

signal fleet_changed
signal fleet_order_changed(order_id: String, order_label: String)
signal ally_destroyed(ally_ship: Node)

const MAX_ALLIES := 3
const REPAIR_HEALTH_PER_WOOD := 5

const ORDER_FOLLOW := "follow"
const ORDER_ATTACK := "attack"
const ORDER_PROTECT := "protect"
const ORDER_FLEE := "flee"

const ORDER_LABELS := {
	"follow": "Suivre",
	"attack": "Attaquer",
	"protect": "Protéger",
	"flee": "Fuir",
}

const ALLY_RECRUIT_COSTS := [
	{"gold": 150, "wood": 60},
	{"gold": 250, "wood": 100},
	{"gold": 400, "wood": 160},
]

@export var ally_ship_scene: PackedScene = preload("res://scenes/boats/AllyShip.tscn")
@export var order_shortcuts_enabled: bool = true
@export var formation_rear_offset: float = 12.0
@export var formation_side_offset: float = 6.0
@export var formation_center_extra_rear_offset: float = 7.0

var _world: Node3D
var _player: Node3D
var _hud: Node
var _allies: Array[Node3D] = []
var _current_order: String = ORDER_FOLLOW


func _ready() -> void:
	add_to_group("fleet_manager")


func setup(world: Node3D, player: Node3D, hud: Node) -> void:
	_world = world
	_player = player
	_hud = hud
	_sync_existing_allies()
	_emit_fleet_changed()
	fleet_order_changed.emit(_current_order, get_current_order_label())


func recruit_ally() -> String:
	_cleanup_allies()
	if is_full():
		_show_hud_message("Flotte complète", 1.8)
		return "Flotte complète"
	if ally_ship_scene == null:
		return "Recrutement indisponible"

	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("spend_resources"):
		return "Recrutement indisponible"

	var cost: Dictionary = get_next_recruit_cost()
	if cost.is_empty():
		_show_hud_message("Flotte complète", 1.8)
		return "Flotte complète"

	var gold_cost: int = int(cost["gold"])
	var wood_cost: int = int(cost["wood"])
	var ally := ally_ship_scene.instantiate()
	if not ally is Node3D:
		ally.queue_free()
		return "Recrutement indisponible"

	if not game_state.spend_resources(gold_cost, wood_cost):
		ally.queue_free()
		return "Ressources insuffisantes - coût : %d or, %d bois" % [gold_cost, wood_cost]

	var ally_node := ally as Node3D
	var parent := _get_spawn_parent()
	parent.add_child(ally_node)
	ally_node.global_position = _get_ally_spawn_position(_allies.size())
	ally_node.global_rotation = _get_ally_spawn_rotation()
	_register_ally(ally_node)

	var ally_number := _allies.find(ally_node) + 1
	var message := "Sloop allié %d recruté" % ally_number
	_show_hud_message(message, 2.0)
	return message


func set_order(order_id: String) -> String:
	if not ORDER_LABELS.has(order_id):
		return "Ordre de flotte indisponible"

	_current_order = order_id
	var label := get_current_order_label()
	fleet_order_changed.emit(_current_order, label)
	_emit_fleet_changed()
	var message := "Ordre flotte : %s" % label
	_show_hud_message(message, 1.6)
	return message


func get_available_order_views() -> Array:
	return [
		_build_order_view(ORDER_FOLLOW, "F"),
		_build_order_view(ORDER_ATTACK, "G"),
		_build_order_view(ORDER_PROTECT, "H"),
		_build_order_view(ORDER_FLEE, "J"),
	]


func get_order_label(order_id: String) -> String:
	return String(ORDER_LABELS.get(order_id, ""))


func get_current_order() -> String:
	return _current_order


func get_current_order_label() -> String:
	return String(ORDER_LABELS.get(_current_order, "Suivre"))


func get_allies() -> Array:
	_cleanup_allies()
	return _allies.duplicate()


func get_first_ally() -> Node:
	_cleanup_allies()
	if _allies.is_empty():
		return null

	return _allies[0]


func get_fleet_count() -> int:
	_cleanup_allies()
	return _allies.size()


func get_max_allies() -> int:
	return MAX_ALLIES


func is_full() -> bool:
	return get_fleet_count() >= MAX_ALLIES


func get_next_recruit_cost() -> Dictionary:
	var index := get_fleet_count()
	if index < 0 or index >= ALLY_RECRUIT_COSTS.size():
		return {}

	var cost: Dictionary = ALLY_RECRUIT_COSTS[index]
	return cost.duplicate()


func get_recruit_status_text() -> String:
	var count := get_fleet_count()
	if count >= MAX_ALLIES:
		return "Flotte complète : %d/%d" % [count, MAX_ALLIES]

	var cost: Dictionary = get_next_recruit_cost()
	return "Flotte : %d/%d - prochain allié : %d or, %d bois" % [
		count,
		MAX_ALLIES,
		int(cost["gold"]),
		int(cost["wood"]),
	]


func get_total_missing_health() -> int:
	_cleanup_allies()
	var missing_health := 0
	for ally in _allies:
		if ally.has_method("get_health") and ally.has_method("get_max_health"):
			missing_health += max(0, int(ally.get_max_health()) - int(ally.get_health()))

	return missing_health


func get_fleet_repair_wood_cost() -> int:
	var missing_health := get_total_missing_health()
	if missing_health <= 0:
		return 0

	return ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))


func repair_fleet() -> String:
	_cleanup_allies()
	if _allies.is_empty():
		return "Aucun allié à réparer"

	var missing_health := get_total_missing_health()
	if missing_health <= 0:
		return "Flotte déjà intacte"

	var required_wood := get_fleet_repair_wood_cost()
	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("spend_resources"):
		return "Pas assez de bois"
	if not game_state.spend_resources(0, required_wood):
		return "Pas assez de bois"

	var repair_pool := required_wood * REPAIR_HEALTH_PER_WOOD
	for ally in _allies:
		if repair_pool <= 0:
			break
		if ally.has_method("repair"):
			var repaired_health: int = ally.repair(repair_pool)
			repair_pool -= repaired_health

	_emit_fleet_changed()
	_show_hud_message("Flotte réparée", 1.6)
	return "Flotte réparée"


func get_follow_slot_for_ally(ally_ship: Node3D) -> Vector3:
	_cleanup_allies()
	var index := _allies.find(ally_ship)
	if index < 0:
		index = 0

	return _get_follow_slot_by_index(index)


func get_safe_slot_for_ally(ally_ship: Node3D) -> Vector3:
	_cleanup_allies()
	var index := _allies.find(ally_ship)
	if index < 0:
		index = 0

	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		var safe_position := port.global_position + _get_spawn_offset(index)
		safe_position.y = 0.0
		return safe_position

	return _get_follow_slot_by_index(index)


func get_fleet_status_lines(max_lines: int = MAX_ALLIES) -> Array:
	_cleanup_allies()
	var lines: Array[String] = [
		"Flotte : %d/%d" % [_allies.size(), MAX_ALLIES],
		"Ordre : %s" % get_current_order_label(),
	]

	var line_count: int = mini(max_lines, _allies.size())
	for index in range(line_count):
		var ally := _allies[index]
		var ally_name := "Sloop %d" % (index + 1)
		if ally.has_method("get_hud_name"):
			ally_name = "%s %d" % [String(ally.get_hud_name()), index + 1]

		var current_health := 0
		var max_health := 0
		if ally.has_method("get_health"):
			current_health = int(ally.get_health())
		if ally.has_method("get_max_health"):
			max_health = int(ally.get_max_health())

		lines.append("%s : %d/%d" % [ally_name, current_health, max_health])

	return lines


func _unhandled_input(event: InputEvent) -> void:
	if not order_shortcuts_enabled or get_tree().paused:
		return
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_F:
			set_order(ORDER_FOLLOW)
		KEY_G:
			set_order(ORDER_ATTACK)
		KEY_H:
			set_order(ORDER_PROTECT)
		KEY_J:
			set_order(ORDER_FLEE)
		_:
			return

	get_viewport().set_input_as_handled()


func _sync_existing_allies() -> void:
	_allies.clear()
	for ally in get_tree().get_nodes_in_group("ally_ships"):
		if ally is Node3D:
			var ally_node := ally as Node3D
			_register_ally(ally_node, false)

	_renumber_allies()


func _register_ally(ally_node: Node3D, emit_change: bool = true) -> void:
	if _allies.has(ally_node):
		return

	_allies.append(ally_node)

	var destroyed_callback := Callable(self, "_on_ally_destroyed").bind(ally_node)
	if ally_node.has_signal("destroyed") and not ally_node.is_connected("destroyed", destroyed_callback):
		ally_node.connect("destroyed", destroyed_callback)

	var health_callback := Callable(self, "_on_ally_health_changed").bind(ally_node)
	if ally_node.has_signal("health_changed") and not ally_node.is_connected("health_changed", health_callback):
		ally_node.connect("health_changed", health_callback)

	_renumber_allies()
	if emit_change:
		_emit_fleet_changed()


func _on_ally_health_changed(_current_health: int, _max_health: int, _ally_ship: Node) -> void:
	_emit_fleet_changed()


func _on_ally_destroyed(ally_ship: Node) -> void:
	_remove_ally(ally_ship)
	ally_destroyed.emit(ally_ship)
	_show_hud_message("Allié détruit", 2.2)


func _remove_ally(ally_ship: Node) -> void:
	var next_allies: Array[Node3D] = []
	for ally in _allies:
		if ally != ally_ship and is_instance_valid(ally):
			next_allies.append(ally)

	_allies = next_allies
	_renumber_allies()
	_emit_fleet_changed()


func _cleanup_allies() -> void:
	var next_allies: Array[Node3D] = []
	var changed := false

	for ally in _allies:
		if ally == null or not is_instance_valid(ally):
			changed = true
			continue
		if ally.has_method("is_destroyed") and ally.is_destroyed():
			changed = true
			continue

		next_allies.append(ally)

	if changed:
		_allies = next_allies
		_renumber_allies()
		_emit_fleet_changed()


func _renumber_allies() -> void:
	for index in range(_allies.size()):
		var ally := _allies[index]
		if ally.has_method("set_fleet_index"):
			ally.set_fleet_index(index + 1)


func _emit_fleet_changed() -> void:
	fleet_changed.emit()
	if _hud == null:
		return
	if _hud.has_method("set_fleet_manager"):
		_hud.set_fleet_manager(self)
	elif _hud.has_method("set_ally_ship"):
		_hud.set_ally_ship(get_first_ally())


func _get_follow_slot_by_index(index: int) -> Vector3:
	if _player == null or not is_instance_valid(_player):
		return Vector3.ZERO

	var rear_direction := _player.global_transform.basis.z
	rear_direction.y = 0.0
	if rear_direction.length_squared() < 0.01:
		rear_direction = Vector3.BACK
	rear_direction = rear_direction.normalized()

	var right_direction := _player.global_transform.basis.x
	right_direction.y = 0.0
	if right_direction.length_squared() < 0.01:
		right_direction = Vector3.RIGHT
	right_direction = right_direction.normalized()

	var follow_slot := _player.global_position
	match index:
		0:
			follow_slot += rear_direction * formation_rear_offset
			follow_slot -= right_direction * formation_side_offset
		1:
			follow_slot += rear_direction * formation_rear_offset
			follow_slot += right_direction * formation_side_offset
		_:
			follow_slot += rear_direction * (formation_rear_offset + formation_center_extra_rear_offset)

	follow_slot.y = 0.0
	return follow_slot


func _get_ally_spawn_position(index: int) -> Vector3:
	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		var spawn_position := port.global_position + _get_spawn_offset(index)
		spawn_position.y = 0.0
		return spawn_position

	if _player != null and is_instance_valid(_player):
		var fallback_position := _player.global_position + _get_spawn_offset(index)
		fallback_position.y = 0.0
		return fallback_position

	return Vector3.ZERO


func _get_spawn_offset(index: int) -> Vector3:
	match index:
		0:
			return Vector3(7.0, 0.0, -6.0)
		1:
			return Vector3(-7.0, 0.0, -6.0)
		_:
			return Vector3(0.0, 0.0, -12.0)


func _get_ally_spawn_rotation() -> Vector3:
	var port := get_tree().get_first_node_in_group("ports") as Node3D
	if port != null:
		return port.global_rotation
	if _player != null and is_instance_valid(_player):
		return _player.global_rotation

	return Vector3.ZERO


func _get_spawn_parent() -> Node:
	if _world != null and is_instance_valid(_world):
		return _world
	if get_tree().current_scene != null:
		return get_tree().current_scene

	return get_tree().root


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _show_hud_message(message: String, duration: float) -> void:
	if _hud != null and _hud.has_method("show_temporary_context_message"):
		_hud.show_temporary_context_message(message, duration)


func _build_order_view(order_id: String, shortcut: String) -> Dictionary:
	return {
		"id": order_id,
		"label": get_order_label(order_id),
		"shortcut": shortcut,
		"active": order_id == _current_order,
	}
