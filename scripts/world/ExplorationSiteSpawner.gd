extends Node3D

@export var site_scene: PackedScene = preload("res://scenes/world/ExplorationSite.tscn")

const SITE_CONFIGS: Array[Dictionary] = [
	{
		"id": "starter_wreck",
		"name": "Epave du depart",
		"type": "epave",
		"danger_zone": TreasureCatalog.DANGER_SAFE,
		"treasure_id": TreasureCatalog.TREASURE_POUCH,
		"position": Vector3(-21.0, 0.0, -4.0),
		"rotation_y": 18.0,
		"scale": Vector3(0.85, 0.85, 0.85),
	},
	{
		"id": "watch_coastal_cave",
		"name": "Grotte cotiere",
		"type": "grotte cotiere",
		"danger_zone": TreasureCatalog.DANGER_WATCHED,
		"treasure_id": TreasureCatalog.TREASURE_CHEST,
		"position": Vector3(42.0, 0.0, -48.0),
		"rotation_y": -28.0,
		"scale": Vector3(1.0, 1.0, 1.0),
	},
	{
		"id": "contested_ruins",
		"name": "Ruines anciennes",
		"type": "ruines anciennes",
		"danger_zone": TreasureCatalog.DANGER_CONTESTED,
		"treasure_id": TreasureCatalog.TREASURE_VAULT,
		"position": Vector3(58.0, 0.0, 76.0),
		"rotation_y": 65.0,
		"scale": Vector3(1.08, 1.0, 1.08),
	},
	{
		"id": "hostile_abandoned_camp",
		"name": "Camp abandonne",
		"type": "camp abandonne",
		"danger_zone": TreasureCatalog.DANGER_HOSTILE,
		"treasure_id": TreasureCatalog.TREASURE_CAVE,
		"position": Vector3(-73.0, 0.0, -30.0),
		"rotation_y": 112.0,
		"scale": Vector3(1.05, 1.0, 1.05),
	},
	{
		"id": "deadly_treasure_island",
		"name": "Ile au tresor",
		"type": "ile au tresor",
		"danger_zone": TreasureCatalog.DANGER_DEADLY,
		"treasure_id": TreasureCatalog.TREASURE_ROYAL,
		"position": Vector3(-94.0, 0.0, 82.0),
		"rotation_y": -44.0,
		"scale": Vector3(1.18, 1.05, 1.18),
	},
]


func _ready() -> void:
	add_to_group("exploration_site_spawner")
	_spawn_sites()


func _spawn_sites() -> void:
	if site_scene == null:
		return

	for config in SITE_CONFIGS:
		var site: Node = site_scene.instantiate()
		if not site is Node3D:
			site.queue_free()
			continue

		var site_node: Node3D = site as Node3D
		add_child(site_node)
		site_node.global_position = config["position"]
		site_node.rotation_degrees = Vector3(0.0, float(config["rotation_y"]), 0.0)
		site_node.scale = config["scale"]
		site_node.set("site_id", String(config["id"]))
		site_node.set("site_name", String(config["name"]))
		site_node.set("site_type", String(config["type"]))
		site_node.set("danger_zone", String(config["danger_zone"]))
		site_node.set("treasure_id", String(config["treasure_id"]))

		if site_node.has_signal("interaction_requested"):
			site_node.connect("interaction_requested", Callable(self, "_on_site_interaction_requested"))


func _on_site_interaction_requested(site: Node) -> void:
	if site.has_method("is_player_in_range") and not bool(site.call("is_player_in_range")):
		return

	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return

	var island_menu: Node = current_scene.get_node_or_null("IslandExplorationMenu")
	if island_menu != null and island_menu.has_method("open"):
		island_menu.call("open", site)
