extends Marker3D

@export var danger_zone: String = "open"


func _ready() -> void:
	add_to_group("enemy_spawn_points")


func get_danger_zone() -> String:
	return danger_zone
