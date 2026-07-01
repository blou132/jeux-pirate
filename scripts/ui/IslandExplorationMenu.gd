extends CanvasLayer

signal closed

@export var hud_message_duration: float = 2.4

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
	status_label.text = _get_exploration_hint_text()
	title_label.text = _get_island_name()
	search_button.text = _get_explore_action_label()
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
		var exploration_result = _island.explore()
		if exploration_result is Dictionary:
			_show_exploration_result(exploration_result)
		else:
			status_label.text = String(exploration_result)
	else:
		status_label.text = "Exploration indisponible"


func _get_island_name() -> String:
	if _island != null and _island.has_method("get_island_name"):
		return _island.get_island_name()

	return "Île inconnue"


func _get_explore_action_label() -> String:
	if _island != null and _island.has_method("get_explore_action_label"):
		return String(_island.call("get_explore_action_label"))

	return "Fouiller l'ile"


func _get_exploration_hint_text() -> String:
	if _island != null and _island.has_method("get_exploration_hint_text"):
		return String(_island.call("get_exploration_hint_text"))

	return ""


func _show_exploration_result(result: Dictionary) -> void:
	var summary := String(result.get("summary", ""))
	status_label.text = summary
	_show_hud_message(summary)


func _show_hud_message(message: String) -> void:
	if message.is_empty():
		return

	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return

	if hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, hud_message_duration)
	elif hud.has_method("set_context_message"):
		hud.set_context_message(message)
