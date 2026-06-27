extends CanvasLayer

@onready var speed_label: Label = $MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var health_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HealthLabel
@onready var resources_label: Label = $MarginContainer/PanelContainer/VBoxContainer/ResourcesLabel

var _player: Node


func _ready() -> void:
	resources_label.visible = false
	call_deferred("_bind_player_from_tree")


func set_player(player: Node) -> void:
	if _player == player:
		return

	_disconnect_player()
	_player = player
	_connect_player()
	_refresh_player_values()


func _bind_player_from_tree() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		set_player(player)


func _connect_player() -> void:
	if _player == null:
		return

	var health_callback := Callable(self, "_on_health_changed")
	if _player.has_signal("health_changed") and not _player.is_connected("health_changed", health_callback):
		_player.connect("health_changed", health_callback)

	var speed_callback := Callable(self, "_on_speed_changed")
	if _player.has_signal("speed_changed") and not _player.is_connected("speed_changed", speed_callback):
		_player.connect("speed_changed", speed_callback)


func _disconnect_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var health_callback := Callable(self, "_on_health_changed")
	if _player.has_signal("health_changed") and _player.is_connected("health_changed", health_callback):
		_player.disconnect("health_changed", health_callback)

	var speed_callback := Callable(self, "_on_speed_changed")
	if _player.has_signal("speed_changed") and _player.is_connected("speed_changed", speed_callback):
		_player.disconnect("speed_changed", speed_callback)


func _refresh_player_values() -> void:
	if _player == null:
		return

	if _player.has_method("get_health") and _player.has_method("get_max_health"):
		_on_health_changed(_player.get_health(), _player.get_max_health())
	if _player.has_method("get_current_speed"):
		_on_speed_changed(_player.get_current_speed())


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "PV: %d/%d" % [current_health, max_health]


func _on_speed_changed(speed: float) -> void:
	speed_label.text = "Vitesse: %.1f nd" % absf(speed)
