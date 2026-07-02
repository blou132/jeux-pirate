extends CanvasLayer

signal closed

const PortCatalog = preload("res://scripts/world/PortCatalog.gd")
const REPAIR_HEALTH_PER_WOOD := 5

@onready var root_control: Control = $Root
@onready var title_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/SubtitleLabel
@onready var port_info_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/PortInfoLabel
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var scroll_container: ScrollContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer
@onready var ports_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PortsButton
@onready var ports_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PortsContainer
@onready var port_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PortsContainer/PortList
@onready var port_services_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PortsContainer/PortServicesLabel
@onready var repair_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/RepairButton
@onready var repair_ally_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/RepairAllyButton
@onready var upgrades_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesButton
@onready var upgrades_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer
@onready var upgrades_ship_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/UpgradesShipLabel
@onready var hull_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/HullStatusLabel
@onready var sails_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/SailsStatusLabel
@onready var cannons_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/CannonsStatusLabel
@onready var hull_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/HullUpgradeButton
@onready var sails_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/SailsUpgradeButton
@onready var cannons_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/UpgradesContainer/CannonsUpgradeButton
@onready var shipyard_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardButton
@onready var shipyard_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer
@onready var current_ship_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/CurrentShipLabel
@onready var ship_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/ShipList
@onready var ship_details_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/ShipDetailsLabel
@onready var ship_hierarchy_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/ShipHierarchyLabel
@onready var buy_ship_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/BuyShipButton
@onready var equip_ship_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/ShipyardContainer/EquipShipButton
@onready var trade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeButton
@onready var trade_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer
@onready var cargo_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer/CargoStatusLabel
@onready var trade_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer/TradeList
@onready var trade_details_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer/TradeDetailsLabel
@onready var buy_trade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer/BuyTradeButton
@onready var sell_trade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/TradeContainer/SellTradeButton
@onready var missions_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsButton
@onready var missions_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer
@onready var missions_intro_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer/MissionsIntroLabel
@onready var mission_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer/MissionList
@onready var mission_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer/MissionStatusLabel
@onready var accept_mission_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer/AcceptMissionButton
@onready var claim_mission_reward_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/MissionsContainer/ClaimMissionRewardButton
@onready var pirate_status_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PirateStatusButton
@onready var pirate_status_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PirateStatusContainer
@onready var pirate_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/PirateStatusContainer/PirateStatusLabel
@onready var faction_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionButton
@onready var faction_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer
@onready var current_faction_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer/CurrentFactionLabel
@onready var faction_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer/FactionList
@onready var faction_details_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer/FactionDetailsLabel
@onready var join_faction_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer/JoinFactionButton
@onready var neutral_faction_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/FactionContainer/NeutralFactionButton
@onready var recruit_ally_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/RecruitAllyButton
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _player: Node
var _reputation_system: Node
var _previous_pause_state: bool = false
var _active_port_id: String = PortCatalog.STARTING_PORT_ID
var _port_ids: Array[String] = []
var _mission_ids: Array[String] = []
var _selected_mission_id: String = ""
var _ship_ids: Array[String] = []
var _selected_ship_id: String = ""
var _trade_good_ids: Array[String] = []
var _selected_trade_good_id: String = ""
var _faction_ids: Array[String] = []
var _selected_faction_id: String = FactionCatalog.FACTION_NEUTRAL


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	ports_container.visible = false
	upgrades_container.visible = false
	shipyard_container.visible = false
	trade_container.visible = false
	missions_container.visible = false
	pirate_status_container.visible = false
	faction_container.visible = false
	ports_button.pressed.connect(_on_ports_pressed)
	port_list.item_selected.connect(_on_port_selected)
	repair_button.pressed.connect(_on_repair_pressed)
	repair_ally_button.pressed.connect(_on_repair_ally_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	hull_upgrade_button.pressed.connect(_on_hull_upgrade_pressed)
	sails_upgrade_button.pressed.connect(_on_sails_upgrade_pressed)
	cannons_upgrade_button.pressed.connect(_on_cannons_upgrade_pressed)
	shipyard_button.pressed.connect(_on_shipyard_pressed)
	ship_list.item_selected.connect(_on_ship_selected)
	buy_ship_button.pressed.connect(_on_buy_ship_pressed)
	equip_ship_button.pressed.connect(_on_equip_ship_pressed)
	trade_button.pressed.connect(_on_trade_pressed)
	trade_list.item_selected.connect(_on_trade_good_selected)
	buy_trade_button.pressed.connect(_on_buy_trade_pressed)
	sell_trade_button.pressed.connect(_on_sell_trade_pressed)
	missions_button.pressed.connect(_on_missions_pressed)
	mission_list.item_selected.connect(_on_mission_selected)
	accept_mission_button.pressed.connect(_on_accept_mission_pressed)
	claim_mission_reward_button.pressed.connect(_on_claim_mission_reward_pressed)
	pirate_status_button.pressed.connect(_on_pirate_status_pressed)
	faction_button.pressed.connect(_on_faction_pressed)
	faction_list.item_selected.connect(_on_faction_selected)
	join_faction_button.pressed.connect(_on_join_faction_pressed)
	neutral_faction_button.pressed.connect(_on_neutral_faction_pressed)
	recruit_ally_button.pressed.connect(_on_recruit_ally_pressed)
	quit_button.pressed.connect(close)
	_connect_reputation_system()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func open(player: Node, port: Node = null) -> void:
	_player = player
	_set_active_port_from_node(port)
	_set_hud_detail_mode(true)
	status_label.text = ""
	ports_container.visible = false
	upgrades_container.visible = false
	shipyard_container.visible = false
	trade_container.visible = false
	missions_container.visible = false
	pirate_status_container.visible = false
	faction_container.visible = false
	_reset_scroll()
	_refresh_port_header()
	_refresh_port_rows()
	_refresh_repair_button()
	_refresh_ally_repair_button()
	_refresh_recruit_ally_button()
	_refresh_upgrade_rows()
	_refresh_shipyard_rows()
	_refresh_trade_rows()
	_refresh_mission_rows()
	_refresh_pirate_status_panel()
	_refresh_faction_rows()
	root_control.visible = true
	_previous_pause_state = get_tree().paused
	get_tree().paused = true


func close() -> void:
	if not is_open():
		return

	root_control.visible = false
	_set_hud_detail_mode(false)
	if not _previous_pause_state:
		get_tree().paused = false
	closed.emit()


func is_open() -> bool:
	return root_control.visible


func _reset_scroll() -> void:
	if scroll_container != null:
		scroll_container.scroll_vertical = 0


func _set_active_port_from_node(port: Node) -> void:
	if port != null and port.has_method("get_port_id"):
		var port_id: String = String(port.call("get_port_id"))
		if PortCatalog.has_port(port_id):
			_active_port_id = port_id

	if not PortCatalog.has_port(_active_port_id):
		_active_port_id = PortCatalog.STARTING_PORT_ID


func _is_service_available(service_id: String) -> bool:
	return PortCatalog.has_service(_active_port_id, service_id)


func _refresh_port_header() -> void:
	title_label.text = PortCatalog.get_port_name(_active_port_id)
	subtitle_label.text = "%s - niveau %d - %s" % [
		PortCatalog.get_port_category(_active_port_id),
		PortCatalog.get_port_level(_active_port_id),
		PortCatalog.get_port_danger_zone(_active_port_id),
	]
	port_info_label.text = "Zone : %s | Commerce niv. %d | Reparation niv. %d | Chantier niv. %d" % [
		PortCatalog.get_port_danger_zone(_active_port_id),
		PortCatalog.get_trade_level(_active_port_id),
		PortCatalog.get_repair_level(_active_port_id),
		PortCatalog.get_shipyard_level(_active_port_id),
	]
	port_info_label.text += "\nServices : %s" % ", ".join(PortCatalog.get_service_names(_active_port_id))
	var territory_text: String = _get_port_territory_text()
	if not territory_text.is_empty():
		port_info_label.text += "\n" + territory_text
	ports_button.text = "Ports disponibles : %s" % PortCatalog.get_port_category(_active_port_id)


func _on_ports_pressed() -> void:
	ports_container.visible = not ports_container.visible
	if ports_container.visible:
		upgrades_container.visible = false
		shipyard_container.visible = false
		trade_container.visible = false
		missions_container.visible = false
		pirate_status_container.visible = false
		faction_container.visible = false
		status_label.text = "Choisis un port"
		_reset_scroll()
		_refresh_port_rows()
	else:
		status_label.text = ""


func _refresh_port_rows() -> void:
	port_list.clear()
	_port_ids.clear()

	var catalog_port_ids: Array[String] = PortCatalog.get_port_ids()
	for port_id in catalog_port_ids:
		_port_ids.append(port_id)
		port_list.add_item(PortCatalog.get_port_row_text(port_id))

	if _port_ids.is_empty():
		port_services_label.text = "Aucun port disponible"
		return

	var selected_index: int = _get_port_index(_active_port_id)
	if selected_index < 0:
		selected_index = 0
		_active_port_id = _port_ids[selected_index]

	port_list.select(selected_index)
	port_services_label.text = PortCatalog.get_port_details_text(_active_port_id)
	var territory_text: String = _get_port_territory_text()
	if not territory_text.is_empty():
		port_services_label.text += "\n\n" + territory_text


func _on_port_selected(index: int) -> void:
	if index < 0 or index >= _port_ids.size():
		return

	_active_port_id = _port_ids[index]
	status_label.text = "Port actif : %s" % PortCatalog.get_port_name(_active_port_id)
	_refresh_port_header()
	_refresh_port_rows()
	_refresh_after_port_change()


func _refresh_after_port_change() -> void:
	if upgrades_container.visible and not _is_service_available(PortCatalog.SERVICE_UPGRADES):
		upgrades_container.visible = false
	if shipyard_container.visible and not _is_service_available(PortCatalog.SERVICE_SHIPYARD):
		shipyard_container.visible = false
	if trade_container.visible and not _is_service_available(PortCatalog.SERVICE_TRADE):
		trade_container.visible = false
	if missions_container.visible and not _is_service_available(PortCatalog.SERVICE_MISSIONS):
		missions_container.visible = false

	_refresh_repair_button()
	_refresh_ally_repair_button()
	_refresh_recruit_ally_button()
	_refresh_upgrade_rows()
	_refresh_shipyard_rows()
	_refresh_trade_rows()
	_refresh_mission_rows()


func _get_port_index(port_id: String) -> int:
	if port_id.is_empty():
		return -1

	for index in range(_port_ids.size()):
		if _port_ids[index] == port_id:
			return index

	return -1


func _set_hud_detail_mode(is_forced: bool) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_detail_hud_forced"):
		hud.set_detail_hud_forced(is_forced)


func _on_repair_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_REPAIR):
		status_label.text = "Reparation indisponible dans ce port"
		_refresh_repair_button()
		return

	if _player == null or not _player.has_method("get_health") or not _player.has_method("get_max_health"):
		status_label.text = "Bateau indisponible"
		_refresh_repair_button()
		return

	var missing_health: int = _player.get_max_health() - _player.get_health()
	if missing_health <= 0:
		status_label.text = "Coque déjà intacte"
		_refresh_repair_button()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("get_wood"):
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	var required_wood: int = ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	if int(game_state.call("get_wood")) < required_wood:
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	if not game_state.has_method("spend_resources") or not bool(game_state.call("spend_resources", 0, required_wood)):
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	var repaired_health: int = 0
	if _player.has_method("repair"):
		repaired_health = int(_player.call("repair", required_wood * REPAIR_HEALTH_PER_WOOD))

	if repaired_health > 0:
		status_label.text = "Bateau réparé"
	else:
		status_label.text = "Coque déjà intacte"
	_refresh_repair_button()
	_refresh_ally_repair_button()


func _on_repair_ally_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_FLEET):
		status_label.text = "Service de flotte indisponible dans ce port"
		_refresh_ally_repair_button()
		return

	var fleet_manager := _get_fleet_manager()
	if fleet_manager != null and fleet_manager.has_method("repair_fleet"):
		status_label.text = fleet_manager.repair_fleet()
		_refresh_ally_repair_button()
		_refresh_repair_button()
		return

	var ally_ship := _get_ally_ship()
	if ally_ship == null:
		status_label.text = "Aucun allié à réparer"
		_refresh_ally_repair_button()
		return
	if not ally_ship.has_method("get_health") or not ally_ship.has_method("get_max_health"):
		status_label.text = "Aucun allié à réparer"
		_refresh_ally_repair_button()
		return

	var missing_health: int = int(ally_ship.get_max_health()) - int(ally_ship.get_health())
	if missing_health <= 0:
		status_label.text = "Allié déjà intact"
		_refresh_ally_repair_button()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("get_wood"):
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	var required_wood: int = ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	if int(game_state.call("get_wood")) < required_wood:
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	if not game_state.has_method("spend_resources") or not bool(game_state.call("spend_resources", 0, required_wood)):
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	var repaired_health: int = 0
	if ally_ship.has_method("repair"):
		repaired_health = int(ally_ship.call("repair", required_wood * REPAIR_HEALTH_PER_WOOD))

	if repaired_health > 0:
		status_label.text = "Allié réparé"
	else:
		status_label.text = "Allié déjà intact"
	_refresh_ally_repair_button()
	_refresh_repair_button()


func _on_upgrades_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_UPGRADES):
		upgrades_container.visible = false
		status_label.text = "Atelier d'ameliorations indisponible dans ce port"
		return

	upgrades_container.visible = not upgrades_container.visible
	if upgrades_container.visible:
		ports_container.visible = false
		shipyard_container.visible = false
		trade_container.visible = false
		missions_container.visible = false
		pirate_status_container.visible = false
		faction_container.visible = false
		status_label.text = "Choisis une amélioration"
		_reset_scroll()
		_refresh_upgrade_rows()
	else:
		status_label.text = ""


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _get_upgrade_system() -> Node:
	return get_node_or_null("/root/UpgradeSystem")


func _get_quest_system() -> Node:
	return get_node_or_null("/root/QuestSystem")


func _get_reputation_system() -> Node:
	return get_node_or_null("/root/ReputationSystem")


func _connect_reputation_system() -> void:
	_reputation_system = _get_reputation_system()
	if _reputation_system == null:
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


func _on_reputation_changed(_points: int, _rank_name: String, _next_rank_name: String, _current_threshold: int, _next_threshold: int) -> void:
	_refresh_pirate_status_if_visible()


func _on_reputation_rank_changed(_rank_name: String, _points: int) -> void:
	_refresh_pirate_status_if_visible()


func _on_pirate_title_changed(_title_name: String, _title_score: int) -> void:
	_refresh_pirate_status_if_visible()


func _refresh_pirate_status_if_visible() -> void:
	if is_open() and pirate_status_container.visible:
		_refresh_pirate_status_panel()


func _get_ally_ship() -> Node:
	var world := get_tree().current_scene
	if world != null and world.has_method("get_ally_ship"):
		return world.get_ally_ship()

	return get_tree().get_first_node_in_group("ally_ships")


func _get_fleet_manager() -> Node:
	var world := get_tree().current_scene
	if world != null and world.has_method("get_fleet_manager"):
		return world.get_fleet_manager()

	return get_tree().get_first_node_in_group("fleet_manager")


func _refresh_repair_button() -> void:
	if not _is_service_available(PortCatalog.SERVICE_REPAIR):
		repair_button.text = "Reparation indisponible : pas d'atelier ici"
		repair_button.disabled = true
		return

	if _player == null or not _player.has_method("get_health") or not _player.has_method("get_max_health"):
		repair_button.text = "Réparer le bateau"
		repair_button.disabled = true
		return

	var missing_health: int = max(0, int(_player.get_max_health()) - int(_player.get_health()))
	if missing_health <= 0:
		repair_button.text = "Coque déjà intacte"
		repair_button.disabled = true
		return

	var required_wood := ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	repair_button.text = "Réparer : %d PV manquants — coût : %d bois" % [
		missing_health,
		required_wood,
	]
	repair_button.disabled = false


func _refresh_ally_repair_button() -> void:
	if not _is_service_available(PortCatalog.SERVICE_FLEET):
		repair_ally_button.text = "Flotte indisponible : pas de capitainerie"
		repair_ally_button.disabled = true
		return

	var fleet_manager := _get_fleet_manager()
	if fleet_manager != null and _refresh_fleet_repair_button(fleet_manager):
		return

	var ally_ship := _get_ally_ship()
	if ally_ship == null or not ally_ship.has_method("get_health") or not ally_ship.has_method("get_max_health"):
		repair_ally_button.text = "Aucun allié à réparer"
		repair_ally_button.disabled = true
		return

	var missing_health: int = max(0, int(ally_ship.get_max_health()) - int(ally_ship.get_health()))
	if missing_health <= 0:
		repair_ally_button.text = "Allié déjà intact"
		repair_ally_button.disabled = true
		return

	var required_wood := ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	repair_ally_button.text = "Réparer allié : %d PV manquants — coût : %d bois" % [
		missing_health,
		required_wood,
	]
	repair_ally_button.disabled = false


func _refresh_fleet_repair_button(fleet_manager: Node) -> bool:
	if not fleet_manager.has_method("get_fleet_count"):
		return false

	var fleet_count := int(fleet_manager.get_fleet_count())
	if fleet_count <= 0:
		repair_ally_button.text = "Aucun allié à réparer"
		repair_ally_button.disabled = true
		return true

	if not fleet_manager.has_method("get_total_missing_health") or not fleet_manager.has_method("get_fleet_repair_wood_cost"):
		return false

	var missing_health := int(fleet_manager.get_total_missing_health())
	if missing_health <= 0:
		repair_ally_button.text = "Flotte déjà intacte"
		repair_ally_button.disabled = true
		return true

	var required_wood := int(fleet_manager.get_fleet_repair_wood_cost())
	repair_ally_button.text = "Réparer la flotte : %d PV manquants - coût : %d bois" % [
		missing_health,
		required_wood,
	]
	repair_ally_button.disabled = false
	return true


func _refresh_recruit_ally_button() -> void:
	if not _is_service_available(PortCatalog.SERVICE_FLEET):
		recruit_ally_button.text = "Recrutement indisponible : pas de capitainerie"
		recruit_ally_button.disabled = true
		return

	var fleet_manager := _get_fleet_manager()
	if fleet_manager == null:
		recruit_ally_button.text = "Recrutement indisponible"
		recruit_ally_button.disabled = true
		return

	var fleet_count := 0
	var max_allies := 3
	if fleet_manager.has_method("get_fleet_count"):
		fleet_count = int(fleet_manager.get_fleet_count())
	if fleet_manager.has_method("get_max_allies"):
		max_allies = int(fleet_manager.get_max_allies())

	if fleet_manager.has_method("is_full") and fleet_manager.is_full():
		recruit_ally_button.text = "Flotte complète : %d/%d" % [fleet_count, max_allies]
		recruit_ally_button.disabled = true
		return

	if fleet_manager.has_method("get_next_recruit_cost"):
		var cost: Dictionary = fleet_manager.get_next_recruit_cost()
		recruit_ally_button.text = "Recruter un allié - Flotte : %d/%d - coût : %d or, %d bois" % [
			fleet_count,
			max_allies,
			int(cost["gold"]),
			int(cost["wood"]),
		]
	else:
		recruit_ally_button.text = "Recruter un allié - Flotte : %d/%d" % [fleet_count, max_allies]

	recruit_ally_button.disabled = false


func _on_hull_upgrade_pressed() -> void:
	_purchase_upgrade("hull")


func _on_sails_upgrade_pressed() -> void:
	_purchase_upgrade("sails")


func _on_cannons_upgrade_pressed() -> void:
	_purchase_upgrade("cannons")


func _purchase_upgrade(upgrade_id: String) -> void:
	if not _is_service_available(PortCatalog.SERVICE_UPGRADES):
		status_label.text = "Atelier d'ameliorations indisponible dans ce port"
		_refresh_upgrade_rows()
		return

	var upgrade_system := _get_upgrade_system()
	if upgrade_system == null or not upgrade_system.has_method("purchase_upgrade"):
		status_label.text = "Améliorations indisponibles"
		return

	status_label.text = upgrade_system.purchase_upgrade(upgrade_id)
	_refresh_repair_button()
	_refresh_upgrade_rows()


func _refresh_upgrade_rows() -> void:
	if not _is_service_available(PortCatalog.SERVICE_UPGRADES):
		upgrades_button.text = "Ameliorations indisponibles : port sans atelier"
		upgrades_button.disabled = true
		upgrades_ship_label.text = "Atelier indisponible dans ce port"
		hull_status_label.text = "Coque renforcee: indisponible"
		sails_status_label.text = "Voiles rapides: indisponible"
		cannons_status_label.text = "Canons ameliores: indisponible"
		hull_upgrade_button.disabled = true
		sails_upgrade_button.disabled = true
		cannons_upgrade_button.disabled = true
		return

	upgrades_button.text = "Ameliorations"
	upgrades_button.disabled = false
	var upgrade_system := _get_upgrade_system()
	if upgrade_system == null:
		upgrades_ship_label.text = "Navire : indisponible"
		hull_status_label.text = "Coque renforcée: indisponible"
		sails_status_label.text = "Voiles rapides: indisponible"
		cannons_status_label.text = "Canons améliorés: indisponible"
		return

	upgrades_ship_label.text = _get_upgrade_ship_context_text()
	_set_upgrade_row(upgrade_system, "hull", hull_status_label, hull_upgrade_button)
	_set_upgrade_row(upgrade_system, "sails", sails_status_label, sails_upgrade_button)
	_set_upgrade_row(upgrade_system, "cannons", cannons_status_label, cannons_upgrade_button)


func _set_upgrade_row(upgrade_system: Node, upgrade_id: String, label: Label, button: Button) -> void:
	if upgrade_system.has_method("get_upgrade_status"):
		label.text = upgrade_system.get_upgrade_status(upgrade_id)

	var block_reason: String = _get_upgrade_service_block_reason(upgrade_system, upgrade_id)
	if not block_reason.is_empty():
		label.text += " - %s" % block_reason
		button.disabled = true
		return

	if upgrade_system.has_method("is_max_level"):
		button.disabled = upgrade_system.is_max_level(upgrade_id)


func _get_upgrade_service_block_reason(upgrade_system: Node, upgrade_id: String) -> String:
	if not _is_service_available(PortCatalog.SERVICE_UPGRADES):
		return "Service indisponible dans ce port"
	if not upgrade_system.has_method("get_level") or not upgrade_system.has_method("get_max_level"):
		return ""

	var level: int = int(upgrade_system.call("get_level", upgrade_id))
	var max_level: int = int(upgrade_system.call("get_max_level", upgrade_id))
	if level >= max_level:
		return ""

	var next_level: int = level + 1
	var port_upgrade_limit: int = PortCatalog.get_shipyard_level(_active_port_id)
	if next_level > port_upgrade_limit:
		return "Atelier trop bas dans ce port (max niv. %d)" % port_upgrade_limit

	return ""


func _get_upgrade_ship_context_text() -> String:
	var game_state: Node = _get_game_state()
	var ship_id: String = ShipCatalog.STARTING_SHIP_ID
	if game_state != null and game_state.has_method("get_active_player_ship_id"):
		ship_id = String(game_state.call("get_active_player_ship_id"))

	return "Navire : %s - max coque %d, voiles %d, canons %d | Atelier port niv. %d" % [
		ShipCatalog.get_ship_name(ship_id),
		ShipCatalog.get_upgrade_limit(ship_id, "hull"),
		ShipCatalog.get_upgrade_limit(ship_id, "sails"),
		ShipCatalog.get_upgrade_limit(ship_id, "cannons"),
		PortCatalog.get_shipyard_level(_active_port_id),
	]


func _on_shipyard_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_SHIPYARD):
		shipyard_container.visible = false
		status_label.text = "Chantier naval indisponible dans ce port"
		return

	shipyard_container.visible = not shipyard_container.visible
	if shipyard_container.visible:
		ports_container.visible = false
		upgrades_container.visible = false
		trade_container.visible = false
		missions_container.visible = false
		pirate_status_container.visible = false
		faction_container.visible = false
		status_label.text = "Chantier naval"
		_reset_scroll()
		_refresh_shipyard_rows()
	else:
		status_label.text = ""


func _refresh_shipyard_rows() -> void:
	ship_list.clear()
	_ship_ids.clear()

	if not _is_service_available(PortCatalog.SERVICE_SHIPYARD):
		shipyard_button.text = "Chantier naval reserve aux ports equipes"
		shipyard_button.disabled = true
		current_ship_label.text = "Chantier naval indisponible"
		ship_details_label.text = "Ce port ne propose pas de chantier naval."
		ship_hierarchy_label.text = _build_ship_hierarchy_text()
		buy_ship_button.disabled = true
		equip_ship_button.disabled = true
		return

	shipyard_button.text = "Chantier naval"
	shipyard_button.disabled = false
	var game_state: Node = _get_game_state()
	if game_state == null:
		current_ship_label.text = "Navire actuel indisponible"
		ship_details_label.text = "Chantier naval indisponible"
		ship_hierarchy_label.text = _build_ship_hierarchy_text()
		buy_ship_button.disabled = true
		equip_ship_button.disabled = true
		return

	var active_ship_id: String = ShipCatalog.STARTING_SHIP_ID
	if game_state.has_method("get_active_player_ship_id"):
		active_ship_id = String(game_state.call("get_active_player_ship_id"))

	current_ship_label.text = "Navire actuel : %s" % ShipCatalog.get_ship_name(active_ship_id)
	ship_hierarchy_label.text = _build_ship_hierarchy_text()
	var ship_ids: Array[String] = PortCatalog.get_port_ship_ids(_active_port_id)
	for ship_id in ship_ids:
		if not ShipCatalog.has_ship(ship_id):
			continue

		_ship_ids.append(ship_id)
		ship_list.add_item(_build_ship_row_text(game_state, ship_id))

	if _ship_ids.is_empty():
		_selected_ship_id = ""
		ship_details_label.text = "Aucun navire disponible"
		buy_ship_button.disabled = true
		equip_ship_button.disabled = true
		return

	var selected_index: int = _get_ship_index(_selected_ship_id)
	if selected_index < 0:
		selected_index = _get_ship_index(active_ship_id)
	if selected_index < 0:
		selected_index = 0

	_selected_ship_id = _ship_ids[selected_index]
	ship_list.select(selected_index)
	_refresh_selected_ship()


func _build_ship_row_text(game_state: Node, ship_id: String) -> String:
	var status: String = ShipCatalog.format_cost(ship_id)
	var owned: bool = false
	if game_state.has_method("is_player_ship_owned"):
		owned = bool(game_state.call("is_player_ship_owned", ship_id))

	var active: bool = false
	if game_state.has_method("get_active_player_ship_id"):
		active = String(game_state.call("get_active_player_ship_id")) == ship_id

	var can_afford: bool = false
	if game_state.has_method("can_afford_player_ship"):
		can_afford = bool(game_state.call("can_afford_player_ship", ship_id))

	var equip_block_reason: String = ""
	if owned and not active and game_state.has_method("get_ship_equip_block_reason"):
		equip_block_reason = String(game_state.call("get_ship_equip_block_reason", ship_id))

	if active:
		status = "navire actuel"
	elif owned and not equip_block_reason.is_empty():
		status = "cargaison trop lourde"
	elif owned:
		status = "possede"
	elif not can_afford:
		status = "ressources insuffisantes"

	return "%s - %s" % [ShipCatalog.get_ship_name(ship_id), status]


func _on_ship_selected(index: int) -> void:
	if index < 0 or index >= _ship_ids.size():
		return

	_selected_ship_id = _ship_ids[index]
	_refresh_selected_ship()


func _refresh_selected_ship() -> void:
	var game_state: Node = _get_game_state()
	if game_state == null or _selected_ship_id.is_empty():
		ship_details_label.text = "Navire indisponible"
		buy_ship_button.disabled = true
		equip_ship_button.disabled = true
		return

	if not PortCatalog.has_ship(_active_port_id, _selected_ship_id):
		ship_details_label.text = "Navire non accessible dans ce port"
		buy_ship_button.disabled = true
		equip_ship_button.disabled = true
		return

	var lines: Array[String] = ShipCatalog.get_ship_stat_lines(_selected_ship_id)

	var owned: bool = false
	if game_state.has_method("is_player_ship_owned"):
		owned = bool(game_state.call("is_player_ship_owned", _selected_ship_id))

	var active: bool = false
	if game_state.has_method("get_active_player_ship_id"):
		active = String(game_state.call("get_active_player_ship_id")) == _selected_ship_id

	var can_afford: bool = false
	if game_state.has_method("can_afford_player_ship"):
		can_afford = bool(game_state.call("can_afford_player_ship", _selected_ship_id))

	var equip_block_reason: String = ""
	if owned and not active and game_state.has_method("get_ship_equip_block_reason"):
		equip_block_reason = String(game_state.call("get_ship_equip_block_reason", _selected_ship_id))

	var can_equip: bool = owned and not active and equip_block_reason.is_empty()

	if active:
		lines.append("Etat : navire actuel")
	elif owned:
		lines.append("Etat : possede")
		if not equip_block_reason.is_empty():
			lines.append("Avertissement : %s" % equip_block_reason)
			lines.append("Vendez ou videz la cargaison avant d'equiper ce navire.")
	elif can_afford:
		lines.append("Etat : disponible a l'achat")
	else:
		lines.append("Etat : ressources insuffisantes")

	ship_details_label.text = "\n".join(lines)
	buy_ship_button.text = "Acheter : %s" % ShipCatalog.format_cost(_selected_ship_id)
	buy_ship_button.disabled = owned or not can_afford
	equip_ship_button.text = "Equiper"
	equip_ship_button.disabled = not can_equip
	if active:
		equip_ship_button.text = "Navire actuel"
	elif not equip_block_reason.is_empty():
		equip_ship_button.text = "Cargaison trop lourde"


func _on_buy_ship_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_SHIPYARD):
		status_label.text = "Chantier naval indisponible dans ce port"
		_refresh_shipyard_rows()
		return
	if not PortCatalog.has_ship(_active_port_id, _selected_ship_id):
		status_label.text = "Navire non accessible dans ce port"
		_refresh_shipyard_rows()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or _selected_ship_id.is_empty() or not game_state.has_method("purchase_player_ship"):
		status_label.text = "Achat indisponible"
		return

	status_label.text = String(game_state.call("purchase_player_ship", _selected_ship_id))
	_refresh_shipyard_rows()
	_refresh_repair_button()
	_refresh_upgrade_rows()


func _on_equip_ship_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_SHIPYARD):
		status_label.text = "Chantier naval indisponible dans ce port"
		_refresh_shipyard_rows()
		return
	if not PortCatalog.has_ship(_active_port_id, _selected_ship_id):
		status_label.text = "Navire non accessible dans ce port"
		_refresh_shipyard_rows()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or _selected_ship_id.is_empty() or not game_state.has_method("equip_player_ship"):
		status_label.text = "Équipement indisponible"
		return

	status_label.text = String(game_state.call("equip_player_ship", _selected_ship_id))
	_refresh_shipyard_rows()
	_refresh_repair_button()
	_refresh_upgrade_rows()


func _get_ship_index(ship_id: String) -> int:
	if ship_id.is_empty():
		return -1

	for index in range(_ship_ids.size()):
		if _ship_ids[index] == ship_id:
			return index

	return -1


func _build_ship_hierarchy_text() -> String:
	var parts: Array[String] = []
	var entries: Array[Dictionary] = ShipCatalog.get_hierarchy_entries()
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var status: String = String(entry.get("status", "à venir"))
		var suffix: String = "max %d" % int(entry.get("upgrade_max", 0))
		if status != "jouable":
			suffix += ", à venir"
		parts.append("%d. %s (%s)" % [index + 1, String(entry.get("name", "Navire")), suffix])

	return "Hiérarchie : %s" % " -> ".join(parts)


func _on_trade_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_TRADE):
		trade_container.visible = false
		status_label.text = "Commerce indisponible dans ce port"
		return

	trade_container.visible = not trade_container.visible
	if trade_container.visible:
		ports_container.visible = false
		upgrades_container.visible = false
		shipyard_container.visible = false
		missions_container.visible = false
		pirate_status_container.visible = false
		faction_container.visible = false
		status_label.text = "Commerce"
		_reset_scroll()
		_refresh_trade_rows()
	else:
		status_label.text = ""


func _refresh_trade_rows() -> void:
	trade_list.clear()
	_trade_good_ids.clear()

	if not _is_service_available(PortCatalog.SERVICE_TRADE):
		trade_button.text = "Commerce indisponible : aucun marche local"
		trade_button.disabled = true
		cargo_status_label.text = "Commerce indisponible dans ce port"
		trade_details_label.text = "Aucune marchandise disponible ici"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	trade_button.text = "Commerce"
	trade_button.disabled = false
	var game_state: Node = _get_game_state()
	if game_state == null:
		cargo_status_label.text = "Cargaison indisponible"
		trade_details_label.text = "Commerce indisponible"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	_refresh_cargo_status(game_state)
	var views: Array = []
	if game_state.has_method("get_trade_good_views"):
		var raw_views: Variant = game_state.call("get_trade_good_views")
		if raw_views is Array:
			views = raw_views

	for trade_view in views:
		if not (trade_view is Dictionary):
			continue

		var view: Dictionary = trade_view
		var item_id: String = String(view.get("id", ""))
		if item_id.is_empty():
			continue
		if not PortCatalog.has_trade_good(_active_port_id, item_id):
			continue

		_trade_good_ids.append(item_id)
		trade_list.add_item(_build_trade_row_text(view))

	if _trade_good_ids.is_empty():
		_selected_trade_good_id = ""
		trade_details_label.text = "Aucune marchandise disponible"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	var selected_index: int = _get_trade_good_index(_selected_trade_good_id)
	if selected_index < 0:
		selected_index = 0
		_selected_trade_good_id = _trade_good_ids[selected_index]

	trade_list.select(selected_index)
	_refresh_selected_trade_good()


func _refresh_cargo_status(game_state: Node) -> void:
	if not game_state.has_method("get_cargo_used") or not game_state.has_method("get_cargo_capacity") or not game_state.has_method("get_cargo_free"):
		cargo_status_label.text = "Cargaison indisponible"
		return

	cargo_status_label.text = "Cargaison : %d/%d - libre : %d" % [
		int(game_state.call("get_cargo_used")),
		int(game_state.call("get_cargo_capacity")),
		int(game_state.call("get_cargo_free")),
	]


func _build_trade_row_text(view: Dictionary) -> String:
	return "%s - x%d - achat %d / vente %d - poids %d" % [
		String(view.get("name", "Marchandise")),
		int(view.get("quantity", 0)),
		int(view.get("buy_price", 0)),
		int(view.get("sell_price", 0)),
		int(view.get("weight", 0)),
	]


func _on_trade_good_selected(index: int) -> void:
	if index < 0 or index >= _trade_good_ids.size():
		return

	_selected_trade_good_id = _trade_good_ids[index]
	_refresh_selected_trade_good()


func _refresh_selected_trade_good() -> void:
	var game_state: Node = _get_game_state()
	if game_state == null or _selected_trade_good_id.is_empty() or not game_state.has_method("get_trade_good_view"):
		trade_details_label.text = "Marchandise indisponible"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	if not PortCatalog.has_trade_good(_active_port_id, _selected_trade_good_id):
		trade_details_label.text = "Marchandise indisponible dans ce port"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	_refresh_cargo_status(game_state)
	var raw_view: Variant = game_state.call("get_trade_good_view", _selected_trade_good_id)
	if not (raw_view is Dictionary):
		trade_details_label.text = "Marchandise indisponible"
		buy_trade_button.disabled = true
		sell_trade_button.disabled = true
		return

	var view: Dictionary = raw_view
	trade_details_label.text = "%s\nQuantite : %d\nPoids unitaire : %d\nAchat : %d or\nVente : %d or\nPlace utilisee : %d" % [
		String(view.get("name", "Marchandise")),
		int(view.get("quantity", 0)),
		int(view.get("weight", 0)),
		int(view.get("buy_price", 0)),
		int(view.get("sell_price", 0)),
		int(view.get("used_space", 0)),
	]
	buy_trade_button.text = "Acheter 1 : %d or" % int(view.get("buy_price", 0))
	sell_trade_button.text = "Vendre 1 : %d or" % int(view.get("sell_price", 0))
	buy_trade_button.disabled = not bool(view.get("can_buy", false))
	sell_trade_button.disabled = not bool(view.get("can_sell", false))


func _on_buy_trade_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_TRADE):
		_set_trade_status("Commerce indisponible dans ce port")
		_refresh_trade_rows()
		return
	if not PortCatalog.has_trade_good(_active_port_id, _selected_trade_good_id):
		_set_trade_status("Marchandise indisponible dans ce port")
		_refresh_trade_rows()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or _selected_trade_good_id.is_empty() or not game_state.has_method("buy_trade_good"):
		_set_trade_status("Commerce indisponible")
		return

	var trade_result: String = String(game_state.call("buy_trade_good", _selected_trade_good_id, 1))
	_set_trade_status(trade_result)
	_record_trade_territory_progress(game_state, trade_result)
	_refresh_trade_rows()


func _on_sell_trade_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_TRADE):
		_set_trade_status("Commerce indisponible dans ce port")
		_refresh_trade_rows()
		return
	if not PortCatalog.has_trade_good(_active_port_id, _selected_trade_good_id):
		_set_trade_status("Marchandise indisponible dans ce port")
		_refresh_trade_rows()
		return

	var game_state: Node = _get_game_state()
	if game_state == null or _selected_trade_good_id.is_empty() or not game_state.has_method("sell_trade_good"):
		_set_trade_status("Commerce indisponible")
		return

	var trade_result: String = String(game_state.call("sell_trade_good", _selected_trade_good_id, 1))
	_set_trade_status(trade_result)
	_record_trade_territory_progress(game_state, trade_result)
	_refresh_trade_rows()


func _record_trade_territory_progress(game_state: Node, trade_result: String) -> void:
	if game_state == null or not game_state.has_method("record_trade_completed"):
		return
	if not trade_result.begins_with("Marchandise achetee") and not trade_result.begins_with("Marchandise vendue"):
		return

	game_state.call("record_trade_completed", _get_active_port_danger_zone_id(), 1)


func _get_active_port_danger_zone_id() -> String:
	return DangerZoneCatalog.normalize_zone_id(PortCatalog.get_port_danger_zone(_active_port_id))


func _get_port_territory_text() -> String:
	var zone_id: String = _get_active_port_danger_zone_id()
	var game_state: Node = _get_game_state()
	if game_state == null:
		return ""

	var lines: Array[String] = []
	if game_state.has_method("get_zone_control"):
		var control_value: Variant = game_state.call("get_zone_control", zone_id)
		if control_value is Dictionary:
			var control: Dictionary = control_value
			lines.append("Controle : %s | Stabilite : %s | Conflit : %s" % [
				String(control.get("dominant_faction_name", "Inconnu")),
				String(control.get("stability", "moyenne")),
				String(control.get("conflict", "moyen")),
			])

	if game_state.has_method("get_zone_effect_lines"):
		var effect_lines_value: Variant = game_state.call("get_zone_effect_lines", zone_id)
		if effect_lines_value is Array:
			for raw_line in effect_lines_value:
				lines.append(String(raw_line))

	if lines.is_empty():
		return ""

	return "Territoire :\n%s" % "\n".join(lines)


func _set_trade_status(message: String) -> void:
	status_label.text = message
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, 1.8)


func _get_trade_good_index(item_id: String) -> int:
	if item_id.is_empty():
		return -1

	for index in range(_trade_good_ids.size()):
		if _trade_good_ids[index] == item_id:
			return index

	return -1


func _on_missions_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_MISSIONS):
		missions_container.visible = false
		status_label.text = "Missions indisponibles dans ce port"
		return

	missions_container.visible = not missions_container.visible
	if missions_container.visible:
		ports_container.visible = false
		upgrades_container.visible = false
		shipyard_container.visible = false
		trade_container.visible = false
		pirate_status_container.visible = false
		faction_container.visible = false
		status_label.text = "Choisis une mission"
		_reset_scroll()
		_refresh_mission_rows()
	else:
		status_label.text = ""


func _on_pirate_status_pressed() -> void:
	pirate_status_container.visible = not pirate_status_container.visible
	if pirate_status_container.visible:
		ports_container.visible = false
		upgrades_container.visible = false
		shipyard_container.visible = false
		trade_container.visible = false
		missions_container.visible = false
		faction_container.visible = false
		status_label.text = "Statut pirate"
		_reset_scroll()
		_refresh_pirate_status_panel()
	else:
		status_label.text = ""


func _refresh_pirate_status_panel() -> void:
	var reputation_system := _get_reputation_system()
	if reputation_system == null or not reputation_system.has_method("get_reputation_view"):
		pirate_status_label.text = "Statut pirate indisponible"
		return

	var view: Dictionary = reputation_system.get_reputation_view()
	var rank_progress: String = String(view.get("progress_text", "0 / 100"))
	var next_rank: String = String(view.get("next_rank_name", "Maximum atteint"))
	if bool(view.get("rank_is_max", false)):
		next_rank = "Maximum atteint"
		rank_progress = "MAX"

	var title_progress: String = String(view.get("title_progress_text", "0 / 120"))
	var next_title: String = String(view.get("next_title_name", "Maximum atteint"))
	if bool(view.get("title_is_max", false)):
		next_title = "Maximum atteint"
		title_progress = "MAX"

	pirate_status_label.text = "Titre pirate : %s\nRenom : %s\nPoints de renom : %d/%d\nProchain rang : %s\nProgression rang : %s\nTitre suivant : %s\nProgression titre : %s" % [
		String(view.get("title_name", "Loup de mer")),
		String(view.get("rank_name", "Inconnu")),
		int(view.get("points", 0)),
		int(view.get("max_points", 3500)),
		next_rank,
		rank_progress,
		next_title,
		title_progress,
	]


func _on_faction_pressed() -> void:
	faction_container.visible = not faction_container.visible
	if faction_container.visible:
		ports_container.visible = false
		upgrades_container.visible = false
		shipyard_container.visible = false
		trade_container.visible = false
		missions_container.visible = false
		pirate_status_container.visible = false
		status_label.text = "Choisis une allegeance"
		_reset_scroll()
		_refresh_faction_rows()
	else:
		status_label.text = ""


func _refresh_faction_rows() -> void:
	faction_list.clear()
	_faction_ids.clear()

	var game_state: Node = _get_game_state()
	var current_faction_id: String = FactionCatalog.FACTION_NEUTRAL
	if game_state != null and game_state.has_method("get_player_faction_id"):
		current_faction_id = String(game_state.call("get_player_faction_id"))

	current_faction_label.text = "Faction actuelle : %s\nBonus actif : %s" % [
		FactionCatalog.get_player_faction_name(current_faction_id),
		FactionCatalog.get_player_bonus_summary(current_faction_id),
	]

	for faction_id in FactionCatalog.get_player_faction_ids():
		_faction_ids.append(faction_id)
		faction_list.add_item(_build_faction_row_text(faction_id, current_faction_id))

	var selected_index: int = _get_faction_index(_selected_faction_id)
	if selected_index < 0:
		selected_index = _get_faction_index(current_faction_id)
	if selected_index < 0 and not _faction_ids.is_empty():
		selected_index = 0

	if selected_index >= 0:
		_selected_faction_id = _faction_ids[selected_index]
		faction_list.select(selected_index)

	_refresh_selected_faction()


func _build_faction_row_text(faction_id: String, current_faction_id: String) -> String:
	var status: String = "disponible"
	if faction_id == current_faction_id:
		status = "actuelle"

	return "%s - %s" % [FactionCatalog.get_player_faction_name(faction_id), status]


func _on_faction_selected(index: int) -> void:
	if index < 0 or index >= _faction_ids.size():
		return

	_selected_faction_id = _faction_ids[index]
	_refresh_selected_faction()


func _refresh_selected_faction() -> void:
	if _selected_faction_id.is_empty() or not FactionCatalog.has_player_faction(_selected_faction_id):
		_selected_faction_id = FactionCatalog.FACTION_NEUTRAL

	var game_state: Node = _get_game_state()
	var current_faction_id: String = FactionCatalog.FACTION_NEUTRAL
	if game_state != null and game_state.has_method("get_player_faction_id"):
		current_faction_id = String(game_state.call("get_player_faction_id"))

	faction_details_label.text = "%s\n%s\nStyle : %s\nBonus : %s" % [
		FactionCatalog.get_player_faction_name(_selected_faction_id),
		FactionCatalog.get_player_description(_selected_faction_id),
		_get_player_faction_style(_selected_faction_id),
		FactionCatalog.get_player_bonus_summary(_selected_faction_id),
	]

	join_faction_button.text = "Rejoindre : %s" % FactionCatalog.get_player_faction_name(_selected_faction_id)
	join_faction_button.disabled = game_state == null or _selected_faction_id == current_faction_id
	neutral_faction_button.disabled = game_state == null or current_faction_id == FactionCatalog.FACTION_NEUTRAL


func _on_join_faction_pressed() -> void:
	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("set_player_faction"):
		status_label.text = "Choix de faction indisponible"
		return

	status_label.text = String(game_state.call("set_player_faction", _selected_faction_id))
	_refresh_faction_rows()


func _on_neutral_faction_pressed() -> void:
	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("set_player_faction"):
		status_label.text = "Choix de faction indisponible"
		return

	_selected_faction_id = FactionCatalog.FACTION_NEUTRAL
	status_label.text = String(game_state.call("set_player_faction", FactionCatalog.FACTION_NEUTRAL))
	_refresh_faction_rows()


func _get_faction_index(faction_id: String) -> int:
	if faction_id.is_empty():
		return -1

	for index in range(_faction_ids.size()):
		if _faction_ids[index] == faction_id:
			return index

	return -1


func _get_player_faction_style(faction_id: String) -> String:
	if faction_id == FactionCatalog.FACTION_NEUTRAL:
		return "independance"

	return FactionCatalog.get_style(faction_id)


func _on_mission_selected(index: int) -> void:
	if index < 0 or index >= _mission_ids.size():
		return

	_selected_mission_id = _mission_ids[index]
	_refresh_selected_mission()


func _on_accept_mission_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_MISSIONS):
		status_label.text = "Missions indisponibles dans ce port"
		_refresh_mission_rows()
		return
	if not PortCatalog.has_mission(_active_port_id, _selected_mission_id):
		status_label.text = "Mission indisponible dans ce port"
		_refresh_mission_rows()
		return

	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("accept_quest"):
		status_label.text = "Missions indisponibles"
		return

	status_label.text = quest_system.accept_quest(_selected_mission_id)
	_refresh_mission_rows()


func _on_claim_mission_reward_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_MISSIONS):
		status_label.text = "Missions indisponibles dans ce port"
		_refresh_mission_rows()
		return
	if not PortCatalog.has_mission(_active_port_id, _selected_mission_id):
		status_label.text = "Mission indisponible dans ce port"
		_refresh_mission_rows()
		return

	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("claim_reward"):
		status_label.text = "Missions indisponibles"
		return

	status_label.text = quest_system.claim_reward(_selected_mission_id)
	_refresh_mission_rows()


func _on_recruit_ally_pressed() -> void:
	if not _is_service_available(PortCatalog.SERVICE_FLEET):
		status_label.text = "Recrutement indisponible dans ce port"
		_refresh_recruit_ally_button()
		return

	var world := get_tree().current_scene
	if world == null or not world.has_method("recruit_ally_ship"):
		status_label.text = "Recrutement indisponible"
		return

	status_label.text = world.recruit_ally_ship()
	_refresh_ally_repair_button()
	_refresh_recruit_ally_button()


func _refresh_mission_rows() -> void:
	mission_list.clear()
	_mission_ids.clear()

	if not _is_service_available(PortCatalog.SERVICE_MISSIONS):
		missions_button.text = "Missions indisponibles : pas de contrats"
		missions_button.disabled = true
		missions_intro_label.text = "Aucune mission disponible dans ce port"
		mission_status_label.text = "Change de port pour trouver des contrats."
		accept_mission_button.disabled = true
		claim_mission_reward_button.disabled = true
		return

	missions_button.text = "Missions"
	missions_button.disabled = false
	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("get_all_quest_views"):
		missions_intro_label.text = "Missions indisponibles"
		mission_status_label.text = "Missions indisponibles"
		accept_mission_button.disabled = true
		claim_mission_reward_button.disabled = true
		return

	missions_intro_label.text = _build_missions_intro_text(quest_system)
	var quest_views: Array = quest_system.get_all_quest_views()
	for quest_view in quest_views:
		if not (quest_view is Dictionary):
			continue

		var view: Dictionary = quest_view
		var quest_id: String = String(view.get("id", ""))
		if quest_id.is_empty():
			continue
		if not PortCatalog.has_mission(_active_port_id, quest_id):
			continue

		_mission_ids.append(quest_id)
		mission_list.add_item(_build_mission_row_text(view))

	if _mission_ids.is_empty():
		_selected_mission_id = ""
		mission_status_label.text = "Aucune mission disponible"
		accept_mission_button.disabled = true
		claim_mission_reward_button.disabled = true
		return

	var selected_index := _get_mission_index(_selected_mission_id)
	if selected_index < 0:
		selected_index = 0
		_selected_mission_id = _mission_ids[selected_index]

	mission_list.select(selected_index)
	_refresh_selected_mission()


func _refresh_selected_mission() -> void:
	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("get_quest_view") or _selected_mission_id.is_empty():
		mission_status_label.text = "Missions indisponibles"
		accept_mission_button.disabled = true
		claim_mission_reward_button.disabled = true
		return

	if not PortCatalog.has_mission(_active_port_id, _selected_mission_id):
		mission_status_label.text = "Mission indisponible dans ce port"
		accept_mission_button.disabled = true
		claim_mission_reward_button.disabled = true
		return

	var view: Dictionary = quest_system.get_quest_view(_selected_mission_id)
	mission_status_label.text = "%s\n%s\nObjectif : %s\nProgression : %s\nRécompense : %s\nStatut : %s" % [
		_build_missions_intro_text(quest_system),
		String(view.get("name", "Mission")),
		String(view.get("objective", "")),
		String(view.get("progress_text", "")),
		String(view.get("reward_text", "")),
		String(view.get("status_text", "")),
	]
	accept_mission_button.disabled = not bool(view.get("can_accept", false))
	claim_mission_reward_button.disabled = not bool(view.get("can_claim", false))


func _build_missions_intro_text(quest_system: Node) -> String:
	if quest_system.has_method("get_active_quest_count") and quest_system.has_method("get_max_active_quests"):
		return "Missions actives : %d/%d" % [
			int(quest_system.get_active_quest_count()),
			int(quest_system.get_max_active_quests()),
		]

	return "Missions disponibles"


func _build_mission_row_text(view: Dictionary) -> String:
	var name: String = String(view.get("name", "Mission"))
	var status: String = String(view.get("status_text", "Disponible"))
	var progress: String = String(view.get("progress_text", ""))
	if bool(view.get("active", false)):
		return "[Active] %s - %s" % [name, progress]
	if bool(view.get("completed", false)) and not bool(view.get("reward_claimed", false)):
		return "[Terminée] %s - récompense à récupérer" % name
	if bool(view.get("reward_claimed", false)):
		return "[Récupérée] %s - récompense récupérée" % name

	return "[Disponible] %s - %s" % [name, status]


func _get_mission_index(quest_id: String) -> int:
	if quest_id.is_empty():
		return -1

	for index in range(_mission_ids.size()):
		if _mission_ids[index] == quest_id:
			return index

	return -1
