extends Area3D

@export var zone_message: String = "Zone inconnue"
@export var notification_duration: float = 2.5


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_zone_notification"):
		hud.show_zone_notification(zone_message, notification_duration)
