class_name FactionChoiceScreen
extends CanvasLayer

signal faction_choice_confirmed(faction_id: String, message: String)

@onready var root_control: Control = $Root
@onready var cards_grid: GridContainer = $Root/CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/ContentContainer/CardsGrid
@onready var selected_summary_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/SelectedSummaryLabel
@onready var warning_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/WarningLabel
@onready var prepare_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ActionRow/PrepareButton
@onready var confirm_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ActionRow/ConfirmButton

var _selected_faction_id: String = ""
var _pending_faction_id: String = ""
var _card_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	prepare_button.pressed.connect(_on_prepare_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	_build_faction_cards()
	var faction_ids: Array[String] = FactionCatalog.get_faction_ids()
	if not faction_ids.is_empty():
		_select_faction(faction_ids[0])


func open() -> void:
	if _is_faction_already_locked():
		close()
		return

	_pending_faction_id = ""
	if _selected_faction_id.is_empty():
		var faction_ids: Array[String] = FactionCatalog.get_faction_ids()
		if not faction_ids.is_empty():
			_selected_faction_id = faction_ids[0]
	root_control.visible = true
	_refresh_selection()


func close() -> void:
	root_control.visible = false


func is_open() -> bool:
	return root_control.visible


func _build_faction_cards() -> void:
	for child in cards_grid.get_children():
		child.queue_free()
	_card_buttons.clear()

	for faction_id in FactionCatalog.get_faction_ids():
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(196, 184)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.text = _build_card_text(faction_id)
		button.pressed.connect(Callable(self, "_on_card_pressed").bind(faction_id))
		cards_grid.add_child(button)
		_card_buttons[faction_id] = button


func _build_card_text(faction_id: String) -> String:
	var view: Dictionary = FactionCatalog.get_choice_card_view(faction_id)
	return "%s\n\n%s\n\nAtouts : %s\n\n\"%s\"" % [
		String(view.get("name", "Faction")),
		String(view.get("mood", String(view.get("description", "")))),
		_format_short_list(view.get("strengths", [])),
		String(view.get("slogan", "")),
	]


func _on_card_pressed(faction_id: String) -> void:
	_select_faction(faction_id)


func _select_faction(faction_id: String) -> void:
	if not FactionCatalog.has_faction(faction_id):
		return

	_selected_faction_id = faction_id
	_pending_faction_id = ""
	_refresh_selection()


func _refresh_selection() -> void:
	for raw_faction_id in _card_buttons.keys():
		var faction_id: String = String(raw_faction_id)
		var button: Button = _card_buttons.get(faction_id) as Button
		if button == null:
			continue
		if faction_id == _selected_faction_id:
			button.modulate = Color(1.0, 0.86, 0.48, 1.0)
		else:
			button.modulate = Color(1.0, 1.0, 1.0, 0.82)

	if _selected_faction_id.is_empty():
		selected_summary_label.text = "Selectionnez une faction."
		warning_label.text = ""
		prepare_button.disabled = true
		confirm_button.disabled = true
		return

	var view: Dictionary = FactionCatalog.get_choice_card_view(_selected_faction_id)
	selected_summary_label.text = "%s\n%s\nStyle : %s\nBonus : %s\nAtouts : %s\nFaiblesses : %s\nVoie : %s" % [
		String(view.get("name", "Faction")),
		String(view.get("description", "")),
		String(view.get("style", "")),
		String(view.get("bonus", "")),
		_format_short_list(view.get("strengths", [])),
		_format_short_list(view.get("weaknesses", [])),
		String(view.get("slogan", "")),
	]

	prepare_button.disabled = false
	prepare_button.text = "Preparer le serment"
	confirm_button.disabled = _pending_faction_id != _selected_faction_id
	confirm_button.text = "Confirmer definitivement"
	if _pending_faction_id == _selected_faction_id:
		warning_label.text = "Confirmer cette voie ?\nCe choix est definitif pour cette partie.\nPour jouer une autre faction, il faudra commencer une nouvelle partie."
		prepare_button.text = "Serment prepare"
	else:
		warning_label.text = "Choisissez une voie. Le serment se confirme en deux etapes."


func _on_prepare_pressed() -> void:
	if _selected_faction_id.is_empty():
		return

	_pending_faction_id = _selected_faction_id
	_refresh_selection()


func _on_confirm_pressed() -> void:
	if _pending_faction_id.is_empty():
		return

	var game_state: Node = _get_game_state()
	if game_state == null or not game_state.has_method("lock_player_faction"):
		warning_label.text = "Choix de faction indisponible."
		return

	var lock_result: String = String(game_state.call("lock_player_faction", _pending_faction_id))
	var result_message: String = "Voie choisie : %s\nVotre allegeance est definitive pour cette partie." % FactionCatalog.get_player_faction_name(_pending_faction_id)
	warning_label.text = result_message
	if game_state.has_method("is_player_faction_locked") and bool(game_state.call("is_player_faction_locked")):
		var confirmed_faction_id: String = _pending_faction_id
		close()
		faction_choice_confirmed.emit(confirmed_faction_id, result_message)
	else:
		warning_label.text = lock_result


func _is_faction_already_locked() -> bool:
	var game_state: Node = _get_game_state()
	if game_state != null and game_state.has_method("is_player_faction_locked"):
		return bool(game_state.call("is_player_faction_locked"))

	return false


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _format_short_list(raw_items: Variant) -> String:
	if not (raw_items is Array):
		return "aucun"

	var items: Array[String] = []
	for raw_item in raw_items:
		items.append(String(raw_item))

	if items.is_empty():
		return "aucun"

	return ", ".join(items)
