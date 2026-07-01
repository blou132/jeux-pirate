extends Marker3D

@export var danger_zone: String = DangerZoneCatalog.ZONE_SAFE


func _ready() -> void:
	add_to_group("marine_creature_spawn_points")


func get_danger_zone() -> String:
	return DangerZoneCatalog.normalize_zone_id(danger_zone)
