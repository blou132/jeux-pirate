extends CanvasLayer

@onready var speed_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/SpeedLabel
@onready var ship_health_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ShipHealthLabel
@onready var health_label: Label = $HUDRoot/TopResourceBar/ResourceRow/HealthLabel
@onready var gold_label: Label = $HUDRoot/TopResourceBar/ResourceRow/GoldLabel
@onready var wood_label: Label = $HUDRoot/TopResourceBar/ResourceRow/WoodLabel
@onready var map_fragments_label: Label = $HUDRoot/TopResourceBar/ResourceRow/MapFragmentsLabel
@onready var ancient_relics_label: Label = $HUDRoot/TopResourceBar/ResourceRow/AncientRelicsLabel
@onready var compact_panel: Control = $HUDRoot/CompactSailingPanel
@onready var compact_ship_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactShipLabel
@onready var compact_cargo_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactCargoLabel
@onready var compact_speed_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactSpeedLabel
@onready var compact_danger_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactDangerLabel
@onready var compact_zone_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactZoneLabel
@onready var compact_fleet_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactFleetLabel
@onready var compact_order_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactOrderLabel
@onready var compact_quest_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactQuestLabel
@onready var compact_reputation_label: Label = $HUDRoot/CompactSailingPanel/CompactRow/CompactReputationLabel
@onready var left_status_panel: Control = $HUDRoot/LeftStatusPanel
@onready var ship_name_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ShipNameLabel
@onready var cargo_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/CargoLabel
@onready var hull_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/HullLevelLabel
@onready var sails_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/SailsLevelLabel
@onready var cannons_level_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/CannonsLevelLabel
@onready var danger_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/DangerLabel
@onready var zone_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ZoneLabel
@onready var enemies_defeated_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/EnemiesDefeatedLabel
@onready var ally_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/AllyLabel
@onready var quest_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/QuestLabel
@onready var exploration_progress_label: Label = $HUDRoot/LeftStatusPanel/LeftVBox/ExplorationProgressLabel
@onready var reputation_panel: Control = $HUDRoot/RightReputationPanel
@onready var reputation_label: Label = $HUDRoot/RightReputationPanel/ReputationVBox/ReputationLabel
@onready var reputation_progress_label: Label = $HUDRoot/RightReputationPanel/ReputationVBox/ReputationProgressLabel
@onready var reputation_progress_bar: ProgressBar = $HUDRoot/RightReputationPanel/ReputationVBox/ReputationProgressBar
@onready var pirate_title_label: Label = $HUDRoot/RightReputationPanel/ReputationVBox/PirateTitleLabel
@onready var title_progress_label: Label = $HUDRoot/RightReputationPanel/ReputationVBox/TitleProgressLabel
@onready var bottom_navigation_bar: Control = $HUDRoot/BottomNavigationBar
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
var _detailed_hud_requested: bool = false
var _detailed_hud_forced: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")
	context_panel.visible = false
	context_label.visible = false
	zone_notification_label.visible = false
	_apply_hud_mode()
	_connect_game_state()
	_connect_upgrade_system()
	_connect_quest_system()
	_connect_reputation_system()
	call_deferred("_bind_player_from_tree")
	call_deferred("_bind_fleet_from_tree")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		_detailed_hud_requested = not _detailed_hud_requested
		_apply_hud_mode()
		get_viewport().set_input_as_handled()


func set_detail_hud_forced(is_forced: bool) -> void:
	_detailed_hud_forced = is_forced
	_apply_hud_mode()


func _is_detailed_hud_visible() -> bool:
	return _detailed_hud_requested or _detailed_hud_forced


func _apply_hud_mode() -> void:
	var show_details := _is_detailed_hud_visible()
	compact_panel.visible = not show_details
	left_status_panel.visible = show_details
	reputation_panel.visible = show_details and _reputation_system != null
	bottom_navigation_bar.visible = show_details


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
			_refresh_compact_fleet_label()
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


func _refresh_compact_fleet_label() -> void:
	if _fleet_manager != null and is_instance_valid(_fleet_manager):
		var fleet_count := 0
		var max_allies := 3
		var order_label := "Suivre"
		if _fleet_manager.has_method("get_fleet_count"):
			fleet_count = int(_fleet_manager.get_fleet_count())
		if _fleet_manager.has_method("get_max_allies"):
			max_allies = int(_fleet_manager.get_max_allies())
		if _fleet_manager.has_method("get_current_order_label"):
			order_label = String(_fleet_manager.get_current_order_label())

		compact_fleet_label.text = "Flotte: %d/%d" % [fleet_count, max_allies]
		compact_order_label.text = "Ordre: %s" % order_label
		return

	if _ally_ship == null or not is_instance_valid(_ally_ship):
		compact_fleet_label.text = "Flotte: 0/3"
		compact_order_label.text = "Ordre: Suivre"
		return

	compact_fleet_label.text = "Flotte: 1/3"
	compact_order_label.text = "Ordre: Suivre"


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "[PV] %d/%d" % [current_health, max_health]
	ship_health_label.text = "Coque: %d/%d PV" % [current_health, max_health]


func _on_speed_changed(speed: float) -> void:
	speed_label.text = "Vitesse: %.1f nd" % absf(speed)
	compact_speed_label.text = "Vitesse: %.1f nd" % absf(speed)


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

	var current_zone_callback: Callable = Callable(self, "_on_current_danger_zone_changed")
	if _game_state.has_signal("current_danger_zone_changed") and not _game_state.is_connected("current_danger_zone_changed", current_zone_callback):
		_game_state.connect("current_danger_zone_changed", current_zone_callback)

	if _game_state.has_method("get_current_danger_zone_id") and _game_state.has_method("get_current_danger_zone_name") and _game_state.has_method("get_current_danger_zone_level"):
		_on_current_danger_zone_changed(
			String(_game_state.call("get_current_danger_zone_id")),
			String(_game_state.call("get_current_danger_zone_name")),
			int(_game_state.call("get_current_danger_zone_level"))
		)

	var player_ship_callback := Callable(self, "_on_player_ship_changed")
	if _game_state.has_signal("player_ship_changed") and not _game_state.is_connected("player_ship_changed", player_ship_callback):
		_game_state.connect("player_ship_changed", player_ship_callback)

	var cargo_callback := Callable(self, "_on_cargo_changed")
	if _game_state.has_signal("cargo_changed") and not _game_state.is_connected("cargo_changed", cargo_callback):
		_game_state.connect("cargo_changed", cargo_callback)

	var exploration_callback := Callable(self, "_on_exploration_progress_changed")
	if _game_state.has_signal("exploration_progress_changed") and not _game_state.is_connected("exploration_progress_changed", exploration_callback):
		_game_state.connect("exploration_progress_changed", exploration_callback)

	_refresh_player_ship_label()
	_refresh_cargo_from_game_state()
	_refresh_exploration_progress_from_game_state()


func _on_resources_changed(gold: int, wood: int) -> void:
	gold_label.text = "[Or] %d" % gold
	wood_label.text = "[Bois] %d" % wood


func _on_treasure_resources_changed(map_fragments: int, ancient_relics: int) -> void:
	map_fragments_label.text = "[Fragments] %d" % map_fragments
	ancient_relics_label.text = "[Reliques] %d" % ancient_relics


func _on_danger_changed(danger_level: int, enemies_defeated: int) -> void:
	danger_label.text = "Danger global: %d" % danger_level
	compact_danger_label.text = "Menace: %d" % danger_level
	enemies_defeated_label.text = "Ennemis détruits: %d" % enemies_defeated


func _on_current_danger_zone_changed(_zone_id: String, zone_name: String, zone_level: int) -> void:
	zone_label.text = "Zone: %s (niv. %d)" % [zone_name, zone_level]
	compact_zone_label.text = "Zone: %s" % _get_compact_zone_label(zone_name)


func _get_compact_zone_label(zone_name: String) -> String:
	match zone_name:
		"Eaux sures":
			return "Eaux sures"
		"Zone surveillee":
			return "Surveillee"
		"Zone contestee":
			return "Contestee"
		"Zone hostile":
			return "Hostile"
		"Zone mortelle":
			return "Mortelle"
		"Territoire legendaire":
			return "Legendaire"
		"Enfers des mers":
			return "Enfers"
		_:
			return zone_name


func _on_player_ship_changed(_ship_id: String, _ship_name: String) -> void:
	_refresh_player_ship_label()
	_refresh_upgrade_levels_from_system()
	_refresh_cargo_from_game_state()


func _refresh_player_ship_label() -> void:
	var ship_name := "Barque"
	if _game_state != null and _game_state.has_method("get_active_player_ship_name"):
		ship_name = String(_game_state.get_active_player_ship_name())

	ship_name_label.text = "Navire : %s" % ship_name
	compact_ship_label.text = "Navire: %s" % ship_name


func _refresh_cargo_from_game_state() -> void:
	if _game_state == null:
		_on_cargo_changed({}, 0, 0)
		return
	if not _game_state.has_method("get_cargo_used") or not _game_state.has_method("get_cargo_capacity"):
		_on_cargo_changed({}, 0, 0)
		return

	_on_cargo_changed(
		{},
		int(_game_state.call("get_cargo_used")),
		int(_game_state.call("get_cargo_capacity"))
	)


func _on_cargo_changed(_cargo_items: Dictionary, used: int, capacity: int) -> void:
	var free_space: int = maxi(0, capacity - used)
	cargo_label.text = "Cargaison: %d/%d - libre %d" % [used, capacity, free_space]
	compact_cargo_label.text = "Cargo: %d/%d" % [used, capacity]


func _refresh_exploration_progress_from_game_state() -> void:
	if _game_state == null:
		_on_exploration_progress_changed(0, 0)
		return
	if not _game_state.has_method("get_discovered_treasure_count") or not _game_state.has_method("get_explored_site_count"):
		_on_exploration_progress_changed(0, 0)
		return

	_on_exploration_progress_changed(
		int(_game_state.call("get_discovered_treasure_count")),
		int(_game_state.call("get_explored_site_count"))
	)


func _on_exploration_progress_changed(discovered_treasures: int, explored_sites: int) -> void:
	exploration_progress_label.text = "Exploration: %d tresor(s), %d site(s)" % [
		discovered_treasures,
		explored_sites,
	]


func _connect_reputation_system() -> void:
	_reputation_system = get_node_or_null("/root/ReputationSystem")
	if _reputation_system == null:
		_set_reputation_panel_visible(false)
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
		_set_reputation_panel_visible(false)
		return

	if not _reputation_system.has_method("get_reputation_view"):
		_set_reputation_panel_visible(false)
		return

	var view: Dictionary = _reputation_system.get_reputation_view()
	var points := int(view.get("points", 0))
	var max_points := int(view.get("max_points", points))
	var current_threshold := int(view.get("current_threshold", 0))
	var next_threshold := int(view.get("next_threshold", current_threshold))
	var rank_is_max := bool(view.get("rank_is_max", false))
	var title_is_max := bool(view.get("title_is_max", false))
	var rank_progress := 100.0
	if not rank_is_max and next_threshold > current_threshold:
		rank_progress = clampf(
			(float(points - current_threshold) / float(next_threshold - current_threshold)) * 100.0,
			0.0,
			100.0
		)
	if rank_is_max:
		reputation_label.text = "Renom : %s (%d/%d)" % [
			String(view.get("rank_name", "Inconnu")),
			points,
			max_points,
		]
	else:
		reputation_label.text = "Renom : %s (%d)" % [
			String(view.get("rank_name", "Inconnu")),
			points,
		]
	pirate_title_label.text = "Titre pirate : %s" % String(view.get("title_name", "Loup de mer"))
	if rank_is_max:
		reputation_progress_label.text = "Prochain rang : Maximum atteint"
	else:
		reputation_progress_label.text = "Prochain rang : %s - %s" % [
			String(view.get("next_rank_name", "Maximum atteint")),
			String(view.get("progress_text", "0 / 100")),
		]
	reputation_progress_bar.value = rank_progress
	if title_is_max:
		title_progress_label.text = "Titre maximum atteint"
	else:
		title_progress_label.text = "Titre suivant : %s - %s" % [
			String(view.get("next_title_name", "Maximum atteint")),
			String(view.get("title_progress_text", "0 / 120")),
		]
	compact_reputation_label.text = "Rang: %s\nTitre: %s" % [
		_get_compact_rank_label(String(view.get("rank_name", "Inconnu"))),
		_get_compact_title_label(String(view.get("title_name", "Loup de mer"))),
	]
	_set_reputation_panel_visible(true)


func _get_compact_rank_label(rank_name: String) -> String:
	match rank_name:
		"Roi des pirates":
			return "Roi pirate"
		"Fléau des mers":
			return "Fléau mers"
		_:
			return rank_name


func _get_compact_title_label(title_name: String) -> String:
	match title_name:
		"Seigneur des vagues":
			return "Seigneur vagues"
		"Maître des flottes":
			return "Maître flotte"
		"Conquérant des mers":
			return "Conquérant"
		"Fléau des mers":
			return "Fléau mers"
		"Souverain des mers":
			return "Souverain"
		"Roi des océans":
			return "Roi océans"
		"Empereur des océans":
			return "Empereur océans"
		"Légende éternelle":
			return "Légende"
		_:
			return title_name


func _set_reputation_panel_visible(is_visible: bool) -> void:
	reputation_panel.visible = is_visible and _is_detailed_hud_visible()
	reputation_label.visible = is_visible
	reputation_progress_label.visible = is_visible
	reputation_progress_bar.visible = is_visible
	pirate_title_label.visible = is_visible
	title_progress_label.visible = is_visible


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
		_refresh_upgrade_levels_from_system()


func _on_upgrades_changed(hull_level: int, sails_level: int, cannons_level: int) -> void:
	hull_level_label.text = "Coque: niv. %d/%d" % [hull_level, _get_upgrade_max_level("hull")]
	sails_level_label.text = "Voiles: niv. %d/%d" % [sails_level, _get_upgrade_max_level("sails")]
	cannons_level_label.text = "Canons: niv. %d/%d" % [cannons_level, _get_upgrade_max_level("cannons")]


func _refresh_upgrade_levels_from_system() -> void:
	if _upgrade_system == null:
		_on_upgrades_changed(0, 0, 0)
		return
	if not _upgrade_system.has_method("get_hull_level") or not _upgrade_system.has_method("get_sails_level") or not _upgrade_system.has_method("get_cannons_level"):
		_on_upgrades_changed(0, 0, 0)
		return

	_on_upgrades_changed(
		_upgrade_system.get_hull_level(),
		_upgrade_system.get_sails_level(),
		_upgrade_system.get_cannons_level()
	)


func _get_upgrade_max_level(upgrade_id: String) -> int:
	if _upgrade_system != null and _upgrade_system.has_method("get_max_level"):
		return int(_upgrade_system.get_max_level(upgrade_id))

	return 3


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
		compact_quest_label.text = "Missions: 0"
		return

	var quest_summary := _get_quest_summary_text()
	quest_label.text = quest_summary
	quest_label.visible = not quest_summary.is_empty()
	_refresh_compact_quest_label(quest_summary)


func _refresh_compact_quest_label(quest_summary: String) -> void:
	if quest_summary.is_empty():
		compact_quest_label.text = "Missions: 0"
		return

	var active_count := 0
	if _quest_system != null and _quest_system.has_method("get_active_quest_count"):
		active_count = int(_quest_system.get_active_quest_count())

	if active_count > 1:
		compact_quest_label.text = "Missions: %d actives" % active_count
		return

	var summary_lines := quest_summary.split("\n", false)
	compact_quest_label.text = String(summary_lines[0])


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
