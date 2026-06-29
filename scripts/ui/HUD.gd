extends CanvasLayer

@onready var speed_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/SpeedLabel
@onready var ship_health_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ShipHealthLabel
@onready var health_label: Label = $HUDRoot/TopResourceBar/ResourceRow/HealthLabel
@onready var gold_label: Label = $HUDRoot/TopResourceBar/ResourceRow/GoldLabel
@onready var wood_label: Label = $HUDRoot/TopResourceBar/ResourceRow/WoodLabel
@onready var map_fragments_label: Label = $HUDRoot/TopResourceBar/ResourceRow/MapFragmentsLabel
@onready var ancient_relics_label: Label = $HUDRoot/TopResourceBar/ResourceRow/AncientRelicsLabel
@onready var hull_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/HullLevelLabel
@onready var sails_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/SailsLevelLabel
@onready var cannons_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/CannonsLevelLabel
@onready var danger_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/DangerLabel
@onready var enemies_defeated_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/EnemiesDefeatedLabel
@onready var ally_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/AllyLabel
@onready var reputation_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ReputationLabel
@onready var pirate_title_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/PirateTitleLabel
@onready var quest_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/QuestLabel
@onready var context_panel: Control = $HUDRoot/MessagePanel
@onready var context_label: Label = $HUDRoot/MessagePanel/ContextLabel
@onready var zone_notification_label: Label = $HUDRoot/ZoneNotificationContainer/ZoneNotificationLabel

var _player: Node
var _ally_ship: Node
var _fleet_manager: Node
var _game_state: Node
var _upgrade_system: Node
var _quest_system: Node
var _reputation_system: Node
var _context_message: String = ""
var _temporary_context_message: String = ""
var _temporary_message_version: int = 0
var _current_zone_message: String = ""
var _zone_notification_version: int = 0


func _ready() -> void:
	add_to_group("hud")
	context_panel.visible = false
	context_label.visible = false
	zone_notification_label.visible = false
	_connect_game_state()
	_connect_upgrade_system()
	_connect_quest_system()
	_connect_reputation_system()
	call_deferred("_bind_player_from_tree")
	call_deferred("_bind_fleet_from_tree")


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


func _bind_ally_from_tree() -> void:
	if _fleet_manager != null and is_instance_valid(_fleet_manager):
		return

	var ally_ship := get_tree().get_first_node_in_group("ally_ships")
	set_ally_ship(ally_ship)


func _bind_fleet_from_tree() -> void:
	var fleet_manager: Node
	var world := get_tree().current_scene
	if world != null and world.has_method("get_fleet_manager"):
		fleet_manager = world.get_fleet_manager()
	if fleet_manager == null:
		fleet_manager = get_tree().get_first_node_in_group("fleet_manager")

	if fleet_manager != null:
		set_fleet_manager(fleet_manager)
	else:
		_bind_ally_from_tree()


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


func set_ally_ship(ally_ship: Node) -> void:
	if _fleet_manager != null and is_instance_valid(_fleet_manager):
		_refresh_ally_status()
		return

	if _ally_ship == ally_ship:
		_refresh_ally_status()
		return

	_disconnect_ally()
	_ally_ship = ally_ship
	_connect_ally()
	_refresh_ally_status()


func set_fleet_manager(fleet_manager: Node) -> void:
	if _fleet_manager == fleet_manager:
		_refresh_ally_status()
		return

	_disconnect_fleet_manager()
	_fleet_manager = fleet_manager
	_connect_fleet_manager()
	_refresh_ally_status()


func _connect_ally() -> void:
	if _ally_ship == null:
		return

	var health_callback := Callable(self, "_on_ally_health_changed")
	if _ally_ship.has_signal("health_changed") and not _ally_ship.is_connected("health_changed", health_callback):
		_ally_ship.connect("health_changed", health_callback)

	var destroyed_callback := Callable(self, "_on_ally_destroyed")
	if _ally_ship.has_signal("destroyed") and not _ally_ship.is_connected("destroyed", destroyed_callback):
		_ally_ship.connect("destroyed", destroyed_callback)


func _disconnect_ally() -> void:
	if _ally_ship == null or not is_instance_valid(_ally_ship):
		return

	var health_callback := Callable(self, "_on_ally_health_changed")
	if _ally_ship.has_signal("health_changed") and _ally_ship.is_connected("health_changed", health_callback):
		_ally_ship.disconnect("health_changed", health_callback)

	var destroyed_callback := Callable(self, "_on_ally_destroyed")
	if _ally_ship.has_signal("destroyed") and _ally_ship.is_connected("destroyed", destroyed_callback):
		_ally_ship.disconnect("destroyed", destroyed_callback)


func _connect_fleet_manager() -> void:
	if _fleet_manager == null:
		return

	var fleet_callback := Callable(self, "_on_fleet_changed")
	if _fleet_manager.has_signal("fleet_changed") and not _fleet_manager.is_connected("fleet_changed", fleet_callback):
		_fleet_manager.connect("fleet_changed", fleet_callback)

	var order_callback := Callable(self, "_on_fleet_order_changed")
	if _fleet_manager.has_signal("fleet_order_changed") and not _fleet_manager.is_connected("fleet_order_changed", order_callback):
		_fleet_manager.connect("fleet_order_changed", order_callback)


func _disconnect_fleet_manager() -> void:
	if _fleet_manager == null or not is_instance_valid(_fleet_manager):
		return

	var fleet_callback := Callable(self, "_on_fleet_changed")
	if _fleet_manager.has_signal("fleet_changed") and _fleet_manager.is_connected("fleet_changed", fleet_callback):
		_fleet_manager.disconnect("fleet_changed", fleet_callback)

	var order_callback := Callable(self, "_on_fleet_order_changed")
	if _fleet_manager.has_signal("fleet_order_changed") and _fleet_manager.is_connected("fleet_order_changed", order_callback):
		_fleet_manager.disconnect("fleet_order_changed", order_callback)


func _on_fleet_changed() -> void:
	_refresh_ally_status()


func _on_fleet_order_changed(_order_id: String, _order_label: String) -> void:
	_refresh_ally_status()


func _on_ally_health_changed(_current_health: int, _max_health: int) -> void:
	_refresh_ally_status()


func _on_ally_destroyed() -> void:
	_ally_ship = null
	_refresh_ally_status()


func _refresh_ally_status() -> void:
	if _fleet_manager != null and is_instance_valid(_fleet_manager):
		if _fleet_manager.has_method("get_fleet_status_lines"):
			var fleet_lines: Array = _fleet_manager.get_fleet_status_lines(3)
			ally_label.text = _join_quest_lines(fleet_lines)
			return

	if _ally_ship == null or not is_instance_valid(_ally_ship):
		ally_label.text = "Allié : aucun"
		return
	if _ally_ship.has_method("is_destroyed") and _ally_ship.is_destroyed():
		ally_label.text = "Allié : aucun"
		return

	var ally_name := "Sloop"
	if _ally_ship.has_method("get_hud_name"):
		ally_name = String(_ally_ship.get_hud_name())
	elif _ally_ship.has_method("get_display_name"):
		ally_name = String(_ally_ship.get_display_name())

	var current_health := 0
	if _ally_ship.has_method("get_health"):
		current_health = int(_ally_ship.get_health())

	var max_health := 0
	if _ally_ship.has_method("get_max_health"):
		max_health = int(_ally_ship.get_max_health())

	ally_label.text = "Allié : %s — %d/%d PV" % [ally_name, current_health, max_health]


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "[PV] %d/%d" % [current_health, max_health]
	ship_health_label.text = "Coque: %d/%d PV" % [current_health, max_health]


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

	var treasure_resources_callback := Callable(self, "_on_treasure_resources_changed")
	if _game_state.has_signal("treasure_resources_changed") and not _game_state.is_connected("treasure_resources_changed", treasure_resources_callback):
		_game_state.connect("treasure_resources_changed", treasure_resources_callback)

	if _game_state.has_method("get_map_fragments") and _game_state.has_method("get_ancient_relics"):
		_on_treasure_resources_changed(_game_state.get_map_fragments(), _game_state.get_ancient_relics())

	var danger_callback := Callable(self, "_on_danger_changed")
	if _game_state.has_signal("danger_changed") and not _game_state.is_connected("danger_changed", danger_callback):
		_game_state.connect("danger_changed", danger_callback)

	if _game_state.has_method("get_danger_level") and _game_state.has_method("get_enemies_defeated"):
		_on_danger_changed(_game_state.get_danger_level(), _game_state.get_enemies_defeated())


func _on_resources_changed(gold: int, wood: int) -> void:
	gold_label.text = "[Or] %d" % gold
	wood_label.text = "[Bois] %d" % wood


func _on_treasure_resources_changed(map_fragments: int, ancient_relics: int) -> void:
	map_fragments_label.text = "[Fragments] %d" % map_fragments
	ancient_relics_label.text = "[Reliques] %d" % ancient_relics


func _on_danger_changed(danger_level: int, enemies_defeated: int) -> void:
	danger_label.text = "Danger: %d" % danger_level
	enemies_defeated_label.text = "Ennemis détruits: %d" % enemies_defeated


func _connect_reputation_system() -> void:
	_reputation_system = get_node_or_null("/root/ReputationSystem")
	if _reputation_system == null:
		reputation_label.visible = false
		pirate_title_label.visible = false
		return

	var reputation_callback := Callable(self, "_on_reputation_changed")
	if _reputation_system.has_signal("reputation_changed") and not _reputation_system.is_connected("reputation_changed", reputation_callback):
		_reputation_system.connect("reputation_changed", reputation_callback)

	var rank_callback := Callable(self, "_on_reputation_rank_changed")
	if _reputation_system.has_signal("reputation_rank_changed") and not _reputation_system.is_connected("reputation_rank_changed", rank_callback):
		_reputation_system.connect("reputation_rank_changed", rank_callback)

	var title_callback := Callable(self, "_on_pirate_title_changed")
	if _reputation_system.has_signal("pirate_title_changed") and not _reputation_system.is_connected("pirate_title_changed", title_callback):
		_reputation_system.connect("pirate_title_changed", title_callback)

	_refresh_reputation_labels()


func _on_reputation_changed(_points: int, _rank_name: String, _next_rank_name: String, _current_threshold: int, _next_threshold: int) -> void:
	_refresh_reputation_labels()


func _on_reputation_rank_changed(_rank_name: String, _points: int) -> void:
	_refresh_reputation_labels()


func _on_pirate_title_changed(_title_name: String, _title_score: int) -> void:
	_refresh_reputation_labels()


func _refresh_reputation_labels() -> void:
	if _reputation_system == null:
		reputation_label.visible = false
		pirate_title_label.visible = false
		return

	if not _reputation_system.has_method("get_reputation_view"):
		reputation_label.visible = false
		pirate_title_label.visible = false
		return

	var view: Dictionary = _reputation_system.get_reputation_view()
	reputation_label.text = "Réputation : %s (%d)" % [
		String(view.get("rank_name", "Inconnu")),
		int(view.get("points", 0)),
	]
	pirate_title_label.text = "Titre : %s" % String(view.get("title_name", "Loup de mer"))
	reputation_label.visible = true
	pirate_title_label.visible = true


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
	context_panel.visible = context_label.visible


func show_zone_notification(message: String, duration: float = 2.5) -> void:
	if message == _current_zone_message:
		return

	_current_zone_message = message
	_zone_notification_version += 1
	var notification_version := _zone_notification_version

	zone_notification_label.text = message
	zone_notification_label.visible = true

	await get_tree().create_timer(duration, true).timeout

	if notification_version != _zone_notification_version:
		return

	zone_notification_label.visible = false


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


func _connect_quest_system() -> void:
	_quest_system = get_node_or_null("/root/QuestSystem")
	if _quest_system == null:
		quest_label.visible = false
		return

	var quests_callback := Callable(self, "_on_quests_changed")
	if _quest_system.has_signal("quests_changed") and not _quest_system.is_connected("quests_changed", quests_callback):
		_quest_system.connect("quests_changed", quests_callback)

	var active_callback := Callable(self, "_on_active_quest_changed")
	if _quest_system.has_signal("active_quest_changed") and not _quest_system.is_connected("active_quest_changed", active_callback):
		_quest_system.connect("active_quest_changed", active_callback)

	var active_quests_callback := Callable(self, "_on_active_quests_changed")
	if _quest_system.has_signal("active_quests_changed") and not _quest_system.is_connected("active_quests_changed", active_quests_callback):
		_quest_system.connect("active_quests_changed", active_quests_callback)

	var progress_callback := Callable(self, "_on_quest_progress_changed")
	if _quest_system.has_signal("quest_progress_changed") and not _quest_system.is_connected("quest_progress_changed", progress_callback):
		_quest_system.connect("quest_progress_changed", progress_callback)

	var completed_callback := Callable(self, "_on_quest_completed")
	if _quest_system.has_signal("quest_completed") and not _quest_system.is_connected("quest_completed", completed_callback):
		_quest_system.connect("quest_completed", completed_callback)

	var claimed_callback := Callable(self, "_on_quest_reward_claimed")
	if _quest_system.has_signal("quest_reward_claimed") and not _quest_system.is_connected("quest_reward_claimed", claimed_callback):
		_quest_system.connect("quest_reward_claimed", claimed_callback)

	_refresh_quest_label()


func _on_quests_changed() -> void:
	_refresh_quest_label()


func _on_active_quest_changed(_quest_id: String) -> void:
	_refresh_quest_label()


func _on_active_quests_changed(_quest_ids: Array[String]) -> void:
	_refresh_quest_label()


func _on_quest_progress_changed(_quest_id: String, _progress: int, _target: int) -> void:
	_refresh_quest_label()


func _on_quest_completed(_quest_id: String, _quest_name: String) -> void:
	_refresh_quest_label()


func _on_quest_reward_claimed(_quest_id: String, _quest_name: String) -> void:
	_refresh_quest_label()


func _refresh_quest_label() -> void:
	if _quest_system == null:
		quest_label.visible = false
		return

	var quest_summary := _get_quest_summary_text()
	quest_label.text = quest_summary
	quest_label.visible = not quest_summary.is_empty()


func _get_quest_summary_text() -> String:
	if _quest_system.has_method("get_active_quest_summaries"):
		var summaries: Array = _quest_system.get_active_quest_summaries(3)
		return _join_quest_lines(summaries)

	if _quest_system.has_method("get_active_quest_summary"):
		return _quest_system.get_active_quest_summary()

	return ""


func _join_quest_lines(lines: Array) -> String:
	var text := ""
	for line in lines:
		if not text.is_empty():
			text += "\n"
		text += String(line)

	return text
