extends CanvasLayer

signal closed

const REPAIR_HEALTH_PER_WOOD := 5

@onready var root_control: Control = $Root
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var repair_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RepairButton
@onready var upgrades_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/UpgradesButton
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _player: Node
var _previous_pause_state: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	repair_button.pressed.connect(_on_repair_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
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
	status_label.text = "Améliorations bientôt disponibles"


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")
