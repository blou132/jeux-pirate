extends Node3D

@export var island_scene: PackedScene = preload("res://scenes/world/Island.tscn")

const QUEST_OBJECTIVE_CONFIGS := {
	"first_map_fragment": {
		"name": "Île du Fragment",
		"position": Vector3(58.0, 0.0, -48.0),
		"rotation_y": -22.0,
		"scale": Vector3(0.82, 0.82, 0.82),
		"chest_id": "quest_first_map_fragment_chest",
		"reward_gold": 0,
		"reward_wood": 0,
		"reward_map_fragments": 1,
		"reward_ancient_relics": 0,
	},
	"ancient_relic": {
		"name": "Sanctuaire englouti",
		"position": Vector3(-72.0, 0.0, 54.0),
		"rotation_y": 38.0,
		"scale": Vector3(1.05, 0.9, 1.05),
		"chest_id": "quest_ancient_relic_chest",
		"reward_gold": 0,
		"reward_wood": 0,
		"reward_map_fragments": 0,
		"reward_ancient_relics": 1,
	},
	"return_to_port": {
		"name": "Cargaison perdue",
		"position": Vector3(66.0, 0.0, 28.0),
		"rotation_y": 72.0,
		"scale": Vector3(0.7, 0.72, 0.7),
		"chest_id": "quest_lost_cargo_chest",
		"reward_gold": 0,
		"reward_wood": 0,
		"reward_map_fragments": 0,
		"reward_ancient_relics": 0,
	},
}

var _spawned_objectives: Dictionary = {}


func _ready() -> void:
	add_to_group("quest_objective_spawner")


func spawn_objective_for_quest(quest_id: String) -> void:
	if not QUEST_OBJECTIVE_CONFIGS.has(quest_id):
		return
	if _spawned_objectives.has(quest_id) and is_instance_valid(_spawned_objectives[quest_id]):
		return
	if island_scene == null:
		return

	var objective := island_scene.instantiate()
	if not objective is Node3D:
		objective.queue_free()
		return

	var objective_node := objective as Node3D
	var config: Dictionary = QUEST_OBJECTIVE_CONFIGS[quest_id]
	add_child(objective_node)
	objective_node.global_position = config["position"]
	objective_node.rotation_degrees = Vector3(0.0, float(config["rotation_y"]), 0.0)
	objective_node.scale = config["scale"]

	objective_node.set("island_name", String(config["name"]))
	objective_node.set("chest_id", String(config["chest_id"]))
	objective_node.set("reward_gold", int(config["reward_gold"]))
	objective_node.set("reward_wood", int(config["reward_wood"]))
	objective_node.set("reward_map_fragments", int(config["reward_map_fragments"]))
	objective_node.set("reward_ancient_relics", int(config["reward_ancient_relics"]))

	if objective.has_signal("interaction_requested"):
		objective.connect("interaction_requested", Callable(self, "_on_objective_interaction_requested"))

	_spawned_objectives[quest_id] = objective_node


func get_objective_for_quest(quest_id: String) -> Node:
	if _spawned_objectives.has(quest_id) and is_instance_valid(_spawned_objectives[quest_id]):
		return _spawned_objectives[quest_id]

	return null


func _on_objective_interaction_requested(objective: Node) -> void:
	if objective.has_method("is_player_in_range") and not objective.is_player_in_range():
		return

	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var island_menu := current_scene.get_node_or_null("IslandExplorationMenu")
	if island_menu != null and island_menu.has_method("open"):
		island_menu.open(objective)
