extends CanvasLayer

signal closed

const REPAIR_HEALTH_PER_WOOD := 5

@onready var root_control: Control = $Root
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var repair_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RepairButton
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
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _player: Node
var _previous_pause_state: bool = false
var _mission_ids: Array[String] = []
var _selected_mission_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	upgrades_container.visible = false
	missions_container.visible = false
	repair_button.pressed.connect(_on_repair_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	hull_upgrade_button.pressed.connect(_on_hull_upgrade_pressed)
	sails_upgrade_button.pressed.connect(_on_sails_upgrade_pressed)
	cannons_upgrade_button.pressed.connect(_on_cannons_upgrade_pressed)
	missions_button.pressed.connect(_on_missions_pressed)
	mission_list.item_selected.connect(_on_mission_selected)
	accept_mission_button.pressed.connect(_on_accept_mission_pressed)
	claim_mission_reward_button.pressed.connect(_on_claim_mission_reward_pressed)
	quit_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func open(player: Node) -> void:
	_player = player
	status_label.text = ""
	upgrades_container.visible = false
	missions_container.visible = false
	_refresh_upgrade_rows()
	_refresh_mission_rows()
	root_control.visible = true
	_previous_pause_state = get_tree().paused
	get_tree().paused = true


func close() -> void:
	if not is_open():
		return

	root_control.visible = false
	if not _previous_pause_state:
		get_tree().paused = false
	closed.emit()


func is_open() -> bool:
	return root_control.visible


func _on_repair_pressed() -> void:
	if _player == null or not _player.has_method("get_health") or not _player.has_method("get_max_health"):
		status_label.text = "Bateau indisponible"
		return

	if _player.has_method("is_at_max_health") and _player.is_at_max_health():
		status_label.text = "Coque déjà intacte"
		return

	var game_state := _get_game_state()
	if game_state == null or not game_state.has_method("get_wood") or game_state.get_wood() <= 0:
		status_label.text = "Pas assez de bois"
		return

	var missing_health: int = _player.get_max_health() - _player.get_health()
	var required_wood := ceili(float(missing_health) / float(REPAIR_HEALTH_PER_WOOD))
	var wood_to_spend: int = mini(required_wood, game_state.get_wood())

	if not game_state.has_method("spend_resources") or not game_state.spend_resources(0, wood_to_spend):
		status_label.text = "Pas assez de bois"
		return

	var repaired_health := 0
	if _player.has_method("repair"):
		repaired_health = _player.repair(wood_to_spend * REPAIR_HEALTH_PER_WOOD)

	if repaired_health > 0:
		status_label.text = "Bateau réparé"
	else:
		status_label.text = "Coque déjà intacte"


func _on_upgrades_pressed() -> void:
	upgrades_container.visible = not upgrades_container.visible
	if upgrades_container.visible:
		missions_container.visible = false
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
		status_label.text = "Choisis une mission"
		_refresh_mission_rows()
	else:
		status_label.text = ""


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
