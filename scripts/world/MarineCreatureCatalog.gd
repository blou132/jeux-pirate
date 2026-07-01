class_name MarineCreatureCatalog
extends RefCounted

const CREATURE_FISH := "fish"
const CREATURE_SHARK := "shark"
const CREATURE_SEA_CROCODILE := "sea_crocodile"
const CREATURE_JUVENILE_KRAKEN := "juvenile_kraken"
const CREATURE_SEA_SERPENT := "sea_serpent"
const CREATURE_LEVIATHAN := "leviathan"
const CREATURE_ANCESTRAL_KRAKEN := "ancestral_kraken"
const CREATURE_OCEAN_GOD := "ocean_god"

const BEHAVIOR_PASSIVE := "passive"
const BEHAVIOR_AGGRESSIVE := "aggressive"

const RESOURCE_BLACK_PEARL := "black_pearl"
const RESOURCE_SACRED_CORAL := "sacred_coral"
const RESOURCE_SHARK_TEETH := "shark_teeth"
const RESOURCE_KRAKEN_EYE := "kraken_eye"
const RESOURCE_SERPENT_SCALE := "serpent_scale"
const RESOURCE_LEVIATHAN_HEART := "leviathan_heart"
const RESOURCE_ABYSSAL_INK := "abyssal_ink"
const RESOURCE_ABYSSAL_CORE := "abyssal_core"

const CREATURE_IDS: Array[String] = [
	CREATURE_FISH,
	CREATURE_SHARK,
	CREATURE_SEA_CROCODILE,
	CREATURE_JUVENILE_KRAKEN,
	CREATURE_SEA_SERPENT,
	CREATURE_LEVIATHAN,
	CREATURE_ANCESTRAL_KRAKEN,
	CREATURE_OCEAN_GOD,
]

const CREATURES := {
	CREATURE_FISH: {
		"id": CREATURE_FISH,
		"name": "Poisson",
		"level": 1,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_SAFE,
		"behavior": BEHAVIOR_PASSIVE,
		"implemented": true,
		"max_health": 8,
		"move_speed": 3.2,
		"damage": 0,
		"aggression": 0.0,
		"detection_range": 12.0,
		"chase_leash_distance": 24.0,
		"attack_range": 0.0,
		"attack_cooldown": 2.5,
		"reward_gold": 2,
		"reward_wood": 0,
		"renown_reward": 0,
		"rare_resource_id": RESOURCE_BLACK_PEARL,
		"rare_resource_chance": 0.12,
		"rare_resource_amount": 1,
		"description": "Vie marine passive, surtout utile pour rendre les eaux vivantes.",
		"visual_color": Color(0.18, 0.58, 0.78, 1.0),
		"visual_scale": Vector3(0.8, 0.35, 1.2),
	},
	CREATURE_SHARK: {
		"id": CREATURE_SHARK,
		"name": "Requin",
		"level": 2,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_SAFE,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": true,
		"max_health": 28,
		"move_speed": 6.2,
		"damage": 8,
		"aggression": 0.55,
		"detection_range": 30.0,
		"chase_leash_distance": 58.0,
		"attack_range": 5.0,
		"attack_cooldown": 1.5,
		"reward_gold": 18,
		"reward_wood": 0,
		"renown_reward": 4,
		"rare_resource_id": RESOURCE_SHARK_TEETH,
		"rare_resource_chance": 0.65,
		"rare_resource_amount": 1,
		"description": "Predateur rapide, dangereux seulement a courte portee.",
		"visual_color": Color(0.16, 0.21, 0.25, 1.0),
		"visual_scale": Vector3(1.0, 0.45, 1.8),
	},
	CREATURE_SEA_CROCODILE: {
		"id": CREATURE_SEA_CROCODILE,
		"name": "Crocodile marin",
		"level": 3,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_WATCHED,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": true,
		"max_health": 55,
		"move_speed": 4.3,
		"damage": 12,
		"aggression": 0.65,
		"detection_range": 32.0,
		"chase_leash_distance": 62.0,
		"attack_range": 5.2,
		"attack_cooldown": 1.8,
		"reward_gold": 28,
		"reward_wood": 8,
		"renown_reward": 7,
		"rare_resource_id": RESOURCE_SACRED_CORAL,
		"rare_resource_chance": 0.45,
		"rare_resource_amount": 1,
		"description": "Lent, robuste, plus frequent pres des zones cotieres dangereuses.",
		"visual_color": Color(0.19, 0.34, 0.16, 1.0),
		"visual_scale": Vector3(1.2, 0.38, 2.1),
	},
	CREATURE_SEA_SERPENT: {
		"id": CREATURE_SEA_SERPENT,
		"name": "Serpent de mer",
		"level": 4,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": true,
		"max_health": 72,
		"move_speed": 7.4,
		"damage": 18,
		"aggression": 0.82,
		"detection_range": 38.0,
		"chase_leash_distance": 76.0,
		"attack_range": 5.8,
		"attack_cooldown": 2.0,
		"reward_gold": 55,
		"reward_wood": 0,
		"renown_reward": 14,
		"rare_resource_id": RESOURCE_SERPENT_SCALE,
		"rare_resource_chance": 0.7,
		"rare_resource_amount": 1,
		"description": "Creature agressive et rapide qui annonce les eaux hostiles.",
		"visual_color": Color(0.35, 0.62, 0.55, 1.0),
		"visual_scale": Vector3(0.75, 0.55, 3.0),
	},
	CREATURE_JUVENILE_KRAKEN: {
		"id": CREATURE_JUVENILE_KRAKEN,
		"name": "Kraken juvenile",
		"level": 5,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_HOSTILE,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": true,
		"max_health": 130,
		"move_speed": 3.5,
		"damage": 28,
		"aggression": 0.92,
		"detection_range": 42.0,
		"chase_leash_distance": 84.0,
		"attack_range": 6.8,
		"attack_cooldown": 3.0,
		"reward_gold": 120,
		"reward_wood": 0,
		"renown_reward": 28,
		"rare_resource_id": RESOURCE_KRAKEN_EYE,
		"rare_resource_chance": 0.45,
		"rare_resource_amount": 1,
		"map_fragments_reward": 1,
		"description": "Menace rare, lente et dangereuse, reservee aux eaux avancees.",
		"visual_color": Color(0.38, 0.16, 0.48, 1.0),
		"visual_scale": Vector3(1.7, 0.85, 1.7),
	},
	CREATURE_LEVIATHAN: {
		"id": CREATURE_LEVIATHAN,
		"name": "Leviathan",
		"level": 6,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_LEGENDARY,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": false,
		"description": "Creature majeure reservee a une version future.",
		"rare_resource_id": RESOURCE_LEVIATHAN_HEART,
	},
	CREATURE_ANCESTRAL_KRAKEN: {
		"id": CREATURE_ANCESTRAL_KRAKEN,
		"name": "Kraken ancestral",
		"level": 7,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_LEGENDARY,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": false,
		"description": "Boss marin futur, hors scope v0.15.",
		"rare_resource_id": RESOURCE_ABYSSAL_INK,
	},
	CREATURE_OCEAN_GOD: {
		"id": CREATURE_OCEAN_GOD,
		"name": "Dieu des oceans",
		"level": 8,
		"minimum_danger_zone": DangerZoneCatalog.ZONE_ABYSS,
		"behavior": BEHAVIOR_AGGRESSIVE,
		"implemented": false,
		"description": "Menace mythique reservee a une version beaucoup plus avancee.",
		"rare_resource_id": RESOURCE_ABYSSAL_CORE,
	},
}

const SPAWN_WEIGHTS_BY_ZONE := {
	DangerZoneCatalog.ZONE_SAFE: {CREATURE_FISH: 10, CREATURE_SHARK: 1},
	DangerZoneCatalog.ZONE_WATCHED: {CREATURE_FISH: 6, CREATURE_SHARK: 4, CREATURE_SEA_CROCODILE: 1},
	DangerZoneCatalog.ZONE_CONTESTED: {CREATURE_SHARK: 5, CREATURE_SEA_CROCODILE: 4, CREATURE_SEA_SERPENT: 1},
	DangerZoneCatalog.ZONE_HOSTILE: {CREATURE_SEA_CROCODILE: 4, CREATURE_SEA_SERPENT: 4, CREATURE_JUVENILE_KRAKEN: 1},
	DangerZoneCatalog.ZONE_DEADLY: {CREATURE_SEA_SERPENT: 5, CREATURE_JUVENILE_KRAKEN: 3},
	DangerZoneCatalog.ZONE_LEGENDARY: {},
	DangerZoneCatalog.ZONE_ABYSS: {},
}

const RESOURCE_NAMES := {
	RESOURCE_BLACK_PEARL: "Perle noire",
	RESOURCE_SACRED_CORAL: "Corail sacre",
	RESOURCE_SHARK_TEETH: "Dents de requin",
	RESOURCE_KRAKEN_EYE: "Oeil de kraken",
	RESOURCE_SERPENT_SCALE: "Ecaille de serpent",
	RESOURCE_LEVIATHAN_HEART: "Coeur de leviathan",
	RESOURCE_ABYSSAL_INK: "Encre abyssale",
	RESOURCE_ABYSSAL_CORE: "Noyau abyssal",
}


static func get_creature_ids() -> Array[String]:
	return CREATURE_IDS.duplicate()


static func has_creature(creature_id: String) -> bool:
	return CREATURES.has(creature_id)


static func get_creature(creature_id: String) -> Dictionary:
	if not CREATURES.has(creature_id):
		creature_id = CREATURE_FISH

	var creature: Dictionary = CREATURES[creature_id]
	return creature.duplicate(true)


static func get_creature_name(creature_id: String) -> String:
	var creature: Dictionary = get_creature(creature_id)
	return String(creature.get("name", "Creature marine"))


static func is_creature_implemented(creature_id: String) -> bool:
	var creature: Dictionary = get_creature(creature_id)
	return bool(creature.get("implemented", false))


static func get_creature_level(creature_id: String) -> int:
	var creature: Dictionary = get_creature(creature_id)
	return maxi(1, int(creature.get("level", 1)))


static func get_spawn_weight(creature_id: String, zone_id_or_name: String) -> int:
	if not is_creature_implemented(creature_id):
		return 0

	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var weights: Dictionary = SPAWN_WEIGHTS_BY_ZONE.get(zone_id, {})
	return maxi(0, int(weights.get(creature_id, 0)))


static func get_spawnable_creature_ids_for_zone(zone_id_or_name: String) -> Array[String]:
	var zone_id: String = DangerZoneCatalog.normalize_zone_id(zone_id_or_name)
	var weights: Dictionary = SPAWN_WEIGHTS_BY_ZONE.get(zone_id, {})
	var creature_ids: Array[String] = []
	for raw_id in weights.keys():
		var creature_id: String = String(raw_id)
		if get_spawn_weight(creature_id, zone_id) > 0:
			creature_ids.append(creature_id)

	return creature_ids


static func get_resource_name(resource_id: String) -> String:
	return String(RESOURCE_NAMES.get(resource_id, resource_id))


static func get_creature_summary_lines() -> Array[String]:
	var lines: Array[String] = []
	for creature_id in CREATURE_IDS:
		var creature: Dictionary = get_creature(creature_id)
		var status: String = "v0.15"
		if not bool(creature.get("implemented", false)):
			status = "a venir"
		lines.append(
			"%s - niv. %d - %s - %s"
			% [
				String(creature.get("name", "Creature marine")),
				maxi(1, int(creature.get("level", 1))),
				DangerZoneCatalog.get_zone_name(String(creature.get("minimum_danger_zone", DangerZoneCatalog.ZONE_SAFE))),
				status,
			]
		)

	return lines
