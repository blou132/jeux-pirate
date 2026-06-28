extends CanvasLayer

signal closed

@onready var root_control: Control = $Root
@onready var title_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var search_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/SearchButton
@onready var quit_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitButton

var _island: Node
var _previous_pause_state: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	search_button.pressed.connect(_on_search_pressed)
	quit_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func open(island: Node) -> void:
	_island = island
	status_label.text = ""
	title_label.text = _get_island_name()
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


func _on_search_pressed() -> void:
	if _island == null:
		status_label.text = "Île indisponible"
		return

	if _island.has_method("explore"):
		status_label.text = String(_island.explore())
	else:
		status_label.text = "Exploration indisponible"


func _get_island_name() -> String:
	if _island != null and _island.has_method("get_island_name"):
		return _island.get_island_name()

	return "Île inconnue"
