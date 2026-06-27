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
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _player: Node
var _previous_pause_state: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	upgrades_container.visible = false
	repair_button.pressed.connect(_on_repair_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	hull_upgrade_button.pressed.connect(_on_hull_upgrade_pressed)
	sails_upgrade_button.pressed.connect(_on_sails_upgrade_pressed)
	cannons_upgrade_button.pressed.connect(_on_cannons_upgrade_pressed)
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
	_refresh_upgrade_rows()
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
		status_label.text = "Choisis une amélioration"
		_refresh_upgrade_rows()
	else:
		status_label.text = ""


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _get_upgrade_system() -> Node:
	return get_node_or_null("/root/UpgradeSystem")


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
