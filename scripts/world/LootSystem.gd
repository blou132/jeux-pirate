extends Node3D

@export var marker_lifetime: float = 1.6


func _ready() -> void:
	add_to_group("loot_system")


func drop_from_ship(world_position: Vector3, gold_reward: int, wood_reward: int) -> void:
	_spawn_marker(world_position)

	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("add_resources"):
		game_state.add_resources(gold_reward, wood_reward)


func _spawn_marker(world_position: Vector3) -> void:
	var marker := Node3D.new()
	marker.name = "LootDrop"
	add_child(marker)
	marker.global_position = world_position + Vector3(0.0, 0.55, 0.0)

	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.85, 0.4, 0.85)

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.72, 0.18, 1.0)

	var crate := MeshInstance3D.new()
	crate.name = "Crate"
	crate.mesh = mesh
	crate.material_override = material
	marker.add_child(crate)

	var timer := get_tree().create_timer(marker_lifetime)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(marker):
			marker.queue_free()
	)
