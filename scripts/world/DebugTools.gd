extends Node

# Temporary development helper for testing upgrades and renown without farming.
# Disable debug_enabled or remove this node before turning this into normal gameplay.
@export var debug_enabled: bool = true
@export var resource_amount: int = 100
@export var renown_amount: int = 50
@export var hud_message_duration: float = 1.6


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if not debug_enabled:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			_add_debug_resources(resource_amount, 0)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F2:
			_add_debug_resources(0, resource_amount)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F3:
			_add_debug_renown(renown_amount)
			get_viewport().set_input_as_handled()


func _add_debug_resources(gold_amount: int, wood_amount: int) -> void:
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("add_resources"):
		game_state.add_resources(gold_amount, wood_amount)

	_show_debug_message("Debug: ressources ajoutées")


func _add_debug_renown(amount: int) -> void:
	var reputation_system := get_node_or_null("/root/ReputationSystem")
	var applied := false
	var actual_gain := 0
	if reputation_system != null and reputation_system.has_method("record_debug_reputation"):
		actual_gain = int(reputation_system.record_debug_reputation(amount))
		applied = true
	elif reputation_system != null and reputation_system.has_method("add_reputation"):
		actual_gain = int(reputation_system.add_reputation(amount, "debug_renown"))
		applied = true

	if not applied:
		return

	if actual_gain <= 0:
		_show_debug_message("Debug : renommée maximale atteinte")
	else:
		_show_debug_message("Debug : +%d renommée" % actual_gain)


func _show_debug_message(message: String) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return

	if hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message(message, hud_message_duration)
	elif hud.has_method("set_context_message"):
		hud.set_context_message(message)
