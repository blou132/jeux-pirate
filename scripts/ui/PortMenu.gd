extends CanvasLayer

signal closed

const REPAIR_HEALTH_PER_WOOD := 5

@onready var root_control: Control = $Root
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var repair_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RepairButton
@onready var repair_ally_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RepairAllyButton
@onready var upgrades_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesButton
@onready var upgrades_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer
@onready var hull_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/HullStatusLabel
@onready var sails_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/SailsStatusLabel
@onready var cannons_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/CannonsStatusLabel
@onready var hull_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/HullUpgradeButton
@onready var sails_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/SailsUpgradeButton
@onready var cannons_upgrade_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesContainer/CannonsUpgradeButton
@onready var missions_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsButton
@onready var missions_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer
@onready var missions_intro_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer/MissionsIntroLabel
@onready var mission_list: ItemList = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer/MissionList
@onready var mission_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer/MissionStatusLabel
@onready var accept_mission_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer/AcceptMissionButton
@onready var claim_mission_reward_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MissionsContainer/ClaimMissionRewardButton
@onready var pirate_status_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/PirateStatusButton
@onready var pirate_status_container: VBoxContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/PirateStatusContainer
@onready var pirate_status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/PirateStatusContainer/PirateStatusLabel
@onready var recruit_ally_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RecruitAllyButton
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _player: Node
var _reputation_system: Node
var _previous_pause_state: bool = false
var _mission_ids: Array[String] = []
var _selected_mission_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	upgrades_container.visible = false
	missions_container.visible = false
	pirate_status_container.visible = false
	repair_button.pressed.connect(_on_repair_pressed)
	repair_ally_button.pressed.connect(_on_repair_ally_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	hull_upgrade_button.pressed.connect(_on_hull_upgrade_pressed)
	sails_upgrade_button.pressed.connect(_on_sails_upgrade_pressed)
	cannons_upgrade_button.pressed.connect(_on_cannons_upgrade_pressed)
	missions_button.pressed.connect(_on_missions_pressed)
	mission_list.item_selected.connect(_on_mission_selected)
	accept_mission_button.pressed.connect(_on_accept_mission_pressed)
	claim_mission_reward_button.pressed.connect(_on_claim_mission_reward_pressed)
	pirate_status_button.pressed.connect(_on_pirate_status_pressed)
	recruit_ally_button.pressed.connect(_on_recruit_ally_pressed)
	quit_button.pressed.connect(close)
	_connect_reputation_system()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func open(player: Node) -> void:
	_player = player
	_set_hud_detail_mode(true)
	status_label.text = ""
	upgrades_container.visible = false
	missions_container.visible = false
	pirate_status_container.visible = false
	_refresh_repair_button()
	_refresh_ally_repair_button()
	_refresh_recruit_ally_button()
	_refresh_upgrade_rows()
	_refresh_mission_rows()
	_refresh_pirate_status_panel()
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


func _set_hud_detail_mode(is_forced: bool) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_detail_hud_forced"):
		hud.set_detail_hud_forced(is_forced)


func _on_repair_pressed() -> void:
	if _player == null or not _player.has_method("get_health") or not _player.has_method("get_max_health"):
		status_label.text = "Bateau indisponible"
		_refresh_repair_button()
		return

	var missing_health: int = _player.get_max_health() - _player.get_health()
	if missing_health <= 0:
		status_label.text = "Coque déjà intacte"
		_refresh_repair_button()
		return

	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("get_wood"):
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	var required_wood := ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	if game_state.get_wood() < required_wood:
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	if not game_state.has_method("spend_resources") or not game_state.spend_resources(0, required_wood):
		status_label.text = "Pas assez de bois"
		_refresh_repair_button()
		return

	var repaired_health := 0
	if _player.has_method("repair"):
		repaired_health = _player.repair(required_wood * REPAIR_HEALTH_PER_WOOD)

	if repaired_health > 0:
		status_label.text = "Bateau réparé"
	else:
		status_label.text = "Coque déjà intacte"
	_refresh_repair_button()
	_refresh_ally_repair_button()


func _on_repair_ally_pressed() -> void:
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

	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("get_wood"):
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	var required_wood := ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	if game_state.get_wood() < required_wood:
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	if not game_state.has_method("spend_resources") or not game_state.spend_resources(0, required_wood):
		status_label.text = "Pas assez de bois"
		_refresh_ally_repair_button()
		return

	var repaired_health := 0
	if ally_ship.has_method("repair"):
		repaired_health = ally_ship.repair(required_wood * REPAIR_HEALTH_PER_WOOD)

	if repaired_health > 0:
		status_label.text = "Allié réparé"
	else:
		status_label.text = "Allié déjà intact"
	_refresh_ally_repair_button()
	_refresh_repair_button()


func _on_upgrades_pressed() -> void:
	upgrades_container.visible = not upgrades_container.visible
	if upgrades_container.visible:
		missions_container.visible = false
		pirate_status_container.visible = false
		status_label.text = "Choisis une amélioration"
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
	var upgrade_system := _get_upgrade_system()
	if upgrade_system == null or not upgrade_system.has_method("purchase_upgrade"):
		status_label.text = "Améliorations indisponibles"
		return

	status_label.text = upgrade_system.purchase_upgrade(upgrade_id)
	_refresh_repair_button()
	_refresh_upgrade_rows()


func _refresh_upgrade_rows() -> void:
	var upgrade_system := _get_upgrade_system()
	if upgrade_system == null:
		hull_status_label.text = "Coque renforcée: indisponible"
		sails_status_label.text = "Voiles rapides: indisponible"
		cannons_status_label.text = "Canons améliorés: indisponible"
		return

	_set_upgrade_row(upgrade_system, "hull", hull_status_label, hull_upgrade_button)
	_set_upgrade_row(upgrade_system, "sails", sails_status_label, sails_upgrade_button)
	_set_upgrade_row(upgrade_system, "cannons", cannons_status_label, cannons_upgrade_button)


func _set_upgrade_row(upgrade_system: Node, upgrade_id: String, label: Label, button: Button) -> void:
	if upgrade_system.has_method("get_upgrade_status"):
		label.text = upgrade_system.get_upgrade_status(upgrade_id)

	if upgrade_system.has_method("is_max_level"):
		button.disabled = upgrade_system.is_max_level(upgrade_id)


func _on_missions_pressed() -> void:
	missions_container.visible = not missions_container.visible
	if missions_container.visible:
		upgrades_container.visible = false
		pirate_status_container.visible = false
		status_label.text = "Choisis une mission"
		_refresh_mission_rows()
	else:
		status_label.text = ""


func _on_pirate_status_pressed() -> void:
	pirate_status_container.visible = not pirate_status_container.visible
	if pirate_status_container.visible:
		upgrades_container.visible = false
		missions_container.visible = false
		status_label.text = "Statut pirate"
		_refresh_pirate_status_panel()
	else:
		status_label.text = ""


func _refresh_pirate_status_panel() -> void:
	var reputation_system := _get_reputation_system()
	if reputation_system == null or not reputation_system.has_method("get_reputation_view"):
		pirate_status_label.text = "Statut pirate indisponible"
		return

	var view: Dictionary = reputation_system.get_reputation_view()
	pirate_status_label.text = "Titre : %s\nRéputation : %s\nPoints : %d\nProchain rang : %s\nProgression : %s" % [
		String(view.get("title_name", "Loup de mer")),
		String(view.get("rank_name", "Inconnu")),
		int(view.get("points", 0)),
		String(view.get("next_rank_name", "Rang maximum")),
		String(view.get("progress_text", "0 / 100")),
	]


func _on_mission_selected(index: int) -> void:
	if index < 0 or index >= _mission_ids.size():
		return

	_selected_mission_id = _mission_ids[index]
	_refresh_selected_mission()


func _on_accept_mission_pressed() -> void:
	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("accept_quest"):
		status_label.text = "Missions indisponibles"
		return

	status_label.text = quest_system.accept_quest(_selected_mission_id)
	_refresh_mission_rows()


func _on_claim_mission_reward_pressed() -> void:
	var quest_system := _get_quest_system()
	if quest_system == null or not quest_system.has_method("claim_reward"):
		status_label.text = "Missions indisponibles"
		return

	status_label.text = quest_system.claim_reward(_selected_mission_id)
	_refresh_mission_rows()


func _on_recruit_ally_pressed() -> void:
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
		var quest_id := String(view.get("id", ""))
		if quest_id.is_empty():
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
	var name := String(view.get("name", "Mission"))
	var status := String(view.get("status_text", "Disponible"))
	var progress := String(view.get("progress_text", ""))
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
