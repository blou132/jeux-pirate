class_name TreasureCatalog
extends RefCounted

const TREASURE_POUCH := "pouch"
const TREASURE_CHEST := "chest"
const TREASURE_VAULT := "vault"
const TREASURE_CAVE := "treasure_cave"
const TREASURE_ROYAL := "royal_treasure"
const TREASURE_IMPERIAL := "imperial_treasure"
const TREASURE_MYTHIC := "mythic_treasure"

const DANGER_SAFE := "Eaux sures"
const DANGER_WATCHED := "Zone surveillee"
const DANGER_CONTESTED := "Zone contestee"
const DANGER_HOSTILE := "Zone hostile"
const DANGER_DEADLY := "Zone mortelle"
const DANGER_LEGENDARY := "Territoire legendaire"
const DANGER_ABYSS := "Enfers des mers"

const TREASURE_IDS: Array[String] = [
	TREASURE_POUCH,
	TREASURE_CHEST,
	TREASURE_VAULT,
	TREASURE_CAVE,
	TREASURE_ROYAL,
	TREASURE_IMPERIAL,
	TREASURE_MYTHIC,
]

const TREASURES := {
	"pouch": {
		"id": "pouch",
		"name": "Bourse",
		"level": 1,
		"rarity": "commune",
		"danger_zone": DANGER_SAFE,
		"possible_rewards": "or faible",
		"required_map_fragments": 0,
		"required_ancient_relics": 0,
		"renown_reward": 5,
		"description": "Petite cache de marin, utile pour un depart rapide.",
		"rewards": {"gold": 80, "wood": 20, "map_fragments": 0, "ancient_relics": 0, "cargo": {}},
	},
	"chest": {
		"id": "chest",
		"name": "Coffre",
		"level": 2,
		"rarity": "peu commun",
		"danger_zone": DANGER_SAFE,
		"possible_rewards": "or et bois",
		"required_map_fragments": 0,
		"required_ancient_relics": 0,
		"renown_reward": 10,
		"description": "Coffre de contrebandier encore facile a atteindre.",
		"rewards": {"gold": 180, "wood": 50, "map_fragments": 0, "ancient_relics": 0, "cargo": {}},
	},
	"vault": {
		"id": "vault",
		"name": "Chambre forte",
		"level": 3,
		"rarity": "rare",
		"danger_zone": DANGER_WATCHED,
		"possible_rewards": "or, bois et fragment possible",
		"required_map_fragments": 1,
		"required_ancient_relics": 0,
		"renown_reward": 25,
		"description": "Reserve verrouillee dont l'emplacement demande un fragment de carte.",
		"rewards": {"gold": 350, "wood": 90, "map_fragments": 1, "ancient_relics": 0, "cargo": {}},
	},
	"treasure_cave": {
		"id": "treasure_cave",
		"name": "Cave au tresor",
		"level": 4,
		"rarity": "tres rare",
		"danger_zone": DANGER_CONTESTED,
		"possible_rewards": "or important et marchandises",
		"required_map_fragments": 2,
		"required_ancient_relics": 0,
		"renown_reward": 45,
		"description": "Ancienne cache cotiere remplie d'or et de marchandises.",
		"rewards": {"gold": 650, "wood": 0, "map_fragments": 0, "ancient_relics": 0, "cargo": {"spices": 2, "cloth": 2}},
	},
	"royal_treasure": {
		"id": "royal_treasure",
		"name": "Tresor royal",
		"level": 5,
		"rarity": "epique",
		"danger_zone": DANGER_HOSTILE,
		"possible_rewards": "or important, fragment et renom",
		"required_map_fragments": 3,
		"required_ancient_relics": 0,
		"renown_reward": 80,
		"description": "Butin de couronne perdu dans une zone hostile.",
		"rewards": {"gold": 1000, "wood": 0, "map_fragments": 1, "ancient_relics": 0, "cargo": {}},
	},
	"imperial_treasure": {
		"id": "imperial_treasure",
		"name": "Tresor imperial",
		"level": 6,
		"rarity": "legendaire",
		"danger_zone": DANGER_DEADLY,
		"possible_rewards": "or tres important et relique possible",
		"required_map_fragments": 4,
		"required_ancient_relics": 0,
		"renown_reward": 130,
		"description": "Tresor d'empire qui justifie une expedition preparee.",
		"rewards": {"gold": 1600, "wood": 0, "map_fragments": 0, "ancient_relics": 1, "cargo": {"pearls": 3}},
	},
	"mythic_treasure": {
		"id": "mythic_treasure",
		"name": "Tresor mythique",
		"level": 7,
		"rarity": "mythique",
		"danger_zone": DANGER_LEGENDARY,
		"possible_rewards": "or massif, relique et beaucoup de renom",
		"required_map_fragments": 5,
		"required_ancient_relics": 1,
		"renown_reward": 220,
		"description": "Tresor de legende reserve aux capitaines les mieux prepares.",
		"rewards": {"gold": 2500, "wood": 0, "map_fragments": 0, "ancient_relics": 1, "cargo": {}},
	},
}

const TREASURES_BY_DANGER_ZONE := {
	DANGER_SAFE: [TREASURE_POUCH, TREASURE_CHEST],
	DANGER_WATCHED: [TREASURE_CHEST, TREASURE_VAULT],
	DANGER_CONTESTED: [TREASURE_VAULT, TREASURE_CAVE],
	DANGER_HOSTILE: [TREASURE_CAVE, TREASURE_ROYAL],
	DANGER_DEADLY: [TREASURE_ROYAL, TREASURE_IMPERIAL],
	DANGER_LEGENDARY: [TREASURE_IMPERIAL, TREASURE_MYTHIC],
	DANGER_ABYSS: [TREASURE_MYTHIC],
}


static func get_treasure_ids() -> Array[String]:
	return TREASURE_IDS.duplicate()


static func has_treasure(treasure_id: String) -> bool:
	return TREASURES.has(treasure_id)


static func get_treasure(treasure_id: String) -> Dictionary:
	if not TREASURES.has(treasure_id):
		treasure_id = TREASURE_POUCH

	var treasure: Dictionary = TREASURES[treasure_id]
	return treasure.duplicate(true)


static func get_treasure_name(treasure_id: String) -> String:
	var treasure: Dictionary = get_treasure(treasure_id)
	return String(treasure.get("name", "Tresor"))


static func get_treasure_level(treasure_id: String) -> int:
	var treasure: Dictionary = get_treasure(treasure_id)
	return maxi(1, int(treasure.get("level", 1)))


static func get_treasure_rarity(treasure_id: String) -> String:
	var treasure: Dictionary = get_treasure(treasure_id)
	return String(treasure.get("rarity", "commune"))


static func get_treasure_danger_zone(treasure_id: String) -> String:
	var treasure: Dictionary = get_treasure(treasure_id)
	return String(treasure.get("danger_zone", DANGER_SAFE))


static func get_required_map_fragments(treasure_id: String) -> int:
	var treasure: Dictionary = get_treasure(treasure_id)
	return maxi(0, int(treasure.get("required_map_fragments", 0)))


static func get_required_ancient_relics(treasure_id: String) -> int:
	var treasure: Dictionary = get_treasure(treasure_id)
	return maxi(0, int(treasure.get("required_ancient_relics", 0)))


static func get_renown_reward(treasure_id: String) -> int:
	var treasure: Dictionary = get_treasure(treasure_id)
	return maxi(0, int(treasure.get("renown_reward", 0)))


static func get_rewards(treasure_id: String) -> Dictionary:
	var treasure: Dictionary = get_treasure(treasure_id)
	var rewards: Dictionary = treasure.get("rewards", {})
	return rewards.duplicate(true)


static func get_treasures_for_danger_zone(danger_zone: String) -> Array[String]:
	var raw_ids: Array = TREASURES_BY_DANGER_ZONE.get(danger_zone, [])
	var treasure_ids: Array[String] = []
	for raw_id in raw_ids:
		var treasure_id: String = String(raw_id)
		if has_treasure(treasure_id):
			treasure_ids.append(treasure_id)

	return treasure_ids


static func is_treasure_available_in_danger_zone(treasure_id: String, danger_zone: String) -> bool:
	return get_treasures_for_danger_zone(danger_zone).has(treasure_id)


static func get_default_treasure_for_danger_zone(danger_zone: String) -> String:
	var treasure_ids: Array[String] = get_treasures_for_danger_zone(danger_zone)
	if treasure_ids.is_empty():
		return TREASURE_POUCH

	return treasure_ids[0]


static func get_danger_zone_treasure_text(danger_zone: String) -> String:
	var treasure_names: Array[String] = []
	for treasure_id in get_treasures_for_danger_zone(danger_zone):
		treasure_names.append(get_treasure_name(treasure_id))
	if treasure_names.is_empty():
		return "Aucun tresor defini"

	return ", ".join(treasure_names)


static func get_requirement_text(treasure_id: String) -> String:
	var requirements: Array[String] = []
	var fragments: int = get_required_map_fragments(treasure_id)
	var relics: int = get_required_ancient_relics(treasure_id)
	if fragments > 0:
		requirements.append("%d fragment(s)" % fragments)
	if relics > 0:
		requirements.append("%d relique(s)" % relics)
	if requirements.is_empty():
		return "Aucun fragment requis"

	return ", ".join(requirements)


static func get_reward_text(treasure_id: String) -> String:
	var rewards: Dictionary = get_rewards(treasure_id)
	var parts: Array[String] = []
	var gold: int = maxi(0, int(rewards.get("gold", 0)))
	var wood: int = maxi(0, int(rewards.get("wood", 0)))
	var fragments: int = maxi(0, int(rewards.get("map_fragments", 0)))
	var relics: int = maxi(0, int(rewards.get("ancient_relics", 0)))
	var renown: int = get_renown_reward(treasure_id)
	var cargo: Dictionary = rewards.get("cargo", {})

	if gold > 0:
		parts.append("%d or" % gold)
	if wood > 0:
		parts.append("%d bois" % wood)
	if fragments > 0:
		parts.append("%d fragment" % fragments)
	if relics > 0:
		parts.append("%d relique" % relics)
	for item_id in cargo.keys():
		var item_key: String = String(item_id)
		var amount: int = maxi(0, int(cargo.get(item_key, 0)))
		if amount > 0:
			parts.append("%s x%d" % [CargoCatalog.get_good_name(item_key), amount])
	if renown > 0:
		parts.append("%d renom" % renown)
	if parts.is_empty():
		return "Aucune recompense"

	return ", ".join(parts)


static func get_treasure_summary_lines() -> Array[String]:
	var lines: Array[String] = []
	for treasure_id in TREASURE_IDS:
		lines.append(
			"%s - niv. %d - %s - %s - requis : %s"
			% [
				get_treasure_name(treasure_id),
				get_treasure_level(treasure_id),
				get_treasure_rarity(treasure_id),
				get_treasure_danger_zone(treasure_id),
				get_requirement_text(treasure_id),
			]
		)

	return lines
