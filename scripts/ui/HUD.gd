extends CanvasLayer

@onready var speed_label: Label = $MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var health_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HealthLabel
@onready var gold_label: Label = $MarginContainer/PanelContainer/VBoxContainer/GoldLabel
@onready var wood_label: Label = $MarginContainer/PanelContainer/VBoxContainer/WoodLabel
@onready var hull_level_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HullLevelLabel
@onready var sails_level_label: Label = $MarginContainer/PanelContainer/VBoxContainer/SailsLevelLabel
@onready var cannons_level_label: Label = $MarginContainer/PanelContainer/VBoxContainer/CannonsLevelLabel
@onready var danger_label: Label = $MarginContainer/PanelContainer/VBoxContainer/DangerLabel
@onready var enemies_defeated_label: Label = $MarginContainer/PanelContainer/VBoxContainer/EnemiesDefeatedLabel
@onready var context_label: Label = $MarginContainer/PanelContainer/VBoxContainer/ContextLabel

var _player: Node
var _game_state: Node
var _upgrade_system: Node
var _context_message: String = ""
var _temporary_context_message: String = ""
var _temporary_message_version: int = 0


func _ready() -> void:
	add_to_group("hud")
	context_label.visible = false
	_connect_game_state()
	_connect_upgrade_system()
	call_deferred("_bind_player_from_tree")


func set_player(player: Node) -> void:
	if _player == player:
		return

	_disconnect_player()
	_player = player
	_connect_player()
	_refresh_player_values()


func _bind_player_from_tree() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		set_player(player)


func _connect_player() -> void:
	if _player == null:
		return

	var health_callback := Callable(self, "_on_health_changed")
	if _player.has_signal("health_changed") and not _player.is_connected("health_changed", health_callback):
		_player.connect("health_changed", health_callback)

	var speed_callback := Callable(self, "_on_speed_changed")
	if _player.has_signal("speed_changed") and not _player.is_connected("speed_changed", speed_callback):
		_player.connect("speed_changed", speed_callback)


func _disconnect_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var health_callback := Callable(self, "_on_health_changed")
	if _player.has_signal("health_changed") and _player.is_connected("health_changed", health_callback):
		_player.disconnect("health_changed", health_callback)

	var speed_callback := Callable(self, "_on_speed_changed")
	if _player.has_signal("speed_changed") and _player.is_connected("speed_changed", speed_callback):
		_player.disconnect("speed_changed", speed_callback)


func _refresh_player_values() -> void:
	if _player == null:
		return

	if _player.has_method("get_health") and _player.has_method("get_max_health"):
		_on_health_changed(_player.get_health(), _player.get_max_health())
	if _player.has_method("get_current_speed"):
		_on_speed_changed(_player.get_current_speed())


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "PV: %d/%d" % [current_health, max_health]


func _on_speed_changed(speed: float) -> void:
	speed_label.text = "Vitesse: %.1f nd" % absf(speed)


func _connect_game_state() -> void:
	_game_state = get_node_or_null("/root/GameState")
	if _game_state == null:
		return

	var resources_callback := Callable(self, "_on_resources_changed")
	if _game_state.has_signal("resources_changed") and not _game_state.is_connected("resources_changed", resources_callback):
		_game_state.connect("resources_changed", resources_callback)

	if _game_state.has_method("get_gold") and _game_state.has_method("get_wood"):
		_on_resources_changed(_game_state.get_gold(), _game_state.get_wood())

	var danger_callback := Callable(self, "_on_danger_changed")
	if _game_state.has_signal("danger_changed") and not _game_state.is_connected("danger_changed", danger_callback):
		_game_state.connect("danger_changed", danger_callback)

	if _game_state.has_method("get_danger_level") and _game_state.has_method("get_enemies_defeated"):
		_on_danger_changed(_game_state.get_danger_level(), _game_state.get_enemies_defeated())


func _on_resources_changed(gold: int, wood: int) -> void:
	gold_label.text = "Or: %d" % gold
	wood_label.text = "Bois: %d" % wood


func _on_danger_changed(danger_level: int, enemies_defeated: int) -> void:
	danger_label.text = "Danger: %d" % danger_level
	enemies_defeated_label.text = "Ennemis détruits: %d" % enemies_defeated


func set_context_message(message: String) -> void:
	_context_message = message
	_refresh_context_label()


func show_temporary_context_message(message: String, duration: float = 1.6) -> void:
	_temporary_message_version += 1
	var message_version := _temporary_message_version
	_temporary_context_message = message
	_refresh_context_label()

	await get_tree().create_timer(duration, true).timeout

	if message_version != _temporary_message_version:
		return

	_temporary_context_message = ""
	_refresh_context_label()


func _refresh_context_label() -> void:
	var message := _context_message
	if not _temporary_context_message.is_empty():
		message = _temporary_context_message

	context_label.text = message
	context_label.visible = not message.is_empty()


func _connect_upgrade_system() -> void:
	_upgrade_system = get_node_or_null("/root/UpgradeSystem")
	if _upgrade_system == null:
		return

	var upgrades_callback := Callable(self, "_on_upgrades_changed")
	if _upgrade_system.has_signal("upgrades_changed") and not _upgrade_system.is_connected("upgrades_changed", upgrades_callback):
		_upgrade_system.connect("upgrades_changed", upgrades_callback)

	if _upgrade_system.has_method("get_hull_level") and _upgrade_system.has_method("get_sails_level") and _upgrade_system.has_method("get_cannons_level"):
		_on_upgrades_changed(
			_upgrade_system.get_hull_level(),
			_upgrade_system.get_sails_level(),
			_upgrade_system.get_cannons_level()
		)


func _on_upgrades_changed(hull_level: int, sails_level: int, cannons_level: int) -> void:
	hull_level_label.text = "Coque: niv. %d/3" % hull_level
	sails_level_label.text = "Voiles: niv. %d/3" % sails_level
	cannons_level_label.text = "Canons: niv. %d/3" % cannons_level
