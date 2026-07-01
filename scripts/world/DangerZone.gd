extends Area3D

@export var zone_id: String = DangerZoneCatalog.ZONE_SAFE
@export var zone_message: String = ""
@export var notification_duration: float = 2.5


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var normalized_zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id)
	if not _set_current_danger_zone(normalized_zone_id):
		return

	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_zone_notification"):
		hud.show_zone_notification(_get_notification_message(normalized_zone_id), notification_duration)


func _set_current_danger_zone(normalized_zone_id: String) -> bool:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("set_current_danger_zone"):
		return bool(game_state.call("set_current_danger_zone", normalized_zone_id))

	return true


func _get_notification_message(normalized_zone_id: String) -> String:
	var base_message: String = DangerZoneCatalog.get_entry_message(normalized_zone_id)
	if not zone_message.is_empty():
		base_message = zone_message

	var zone_level: int = DangerZoneCatalog.get_zone_level(normalized_zone_id)
	var reward_multiplier: float = DangerZoneCatalog.get_reward_multiplier(normalized_zone_id)
	if reward_multiplier > 1.0:
		return "%s - niv. %d - bonus x%.2f" % [base_message, zone_level, reward_multiplier]

	return "%s - niv. %d" % [base_message, zone_level]
