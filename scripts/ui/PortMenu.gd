extends CanvasLayer

signal closed

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
	status_label.text = "Réparation bientôt disponible"


func _on_upgrades_pressed() -> void:
	status_label.text = "Améliorations bientôt disponibles"
