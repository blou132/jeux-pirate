class_name DangerZoneCatalog
extends RefCounted

const ZONE_SAFE := "safe_waters"
const ZONE_WATCHED := "watched_zone"
const ZONE_CONTESTED := "contested_zone"
const ZONE_HOSTILE := "hostile_zone"
const ZONE_DEADLY := "deadly_zone"
const ZONE_LEGENDARY := "legendary_territory"
const ZONE_ABYSS := "sea_abyss"

const LEGACY_ZONE_PORT := "port"
const LEGACY_ZONE_ARCHIPELAGO := "archipelago"
const LEGACY_ZONE_HOSTILE := "hostile"

const ZONE_IDS: Array[String] = [
	ZONE_SAFE,
	ZONE_WATCHED,
	ZONE_CONTESTED,
	ZONE_HOSTILE,
	ZONE_DEADLY,
	ZONE_LEGENDARY,
	ZONE_ABYSS,
]

const ZONES := {
	ZONE_SAFE: {
		"id": ZONE_SAFE,
		"name": "Eaux sures",
		"level": 1,
		"description": "Zone de depart protegee, avec peu de menaces.",
		"enemy_types": ["small_pirate"],
		"enemy_density": 0.4,
		"reward_multiplier": 1.0,
		"treasures": [TreasureCatalog.TREASURE_POUCH, TreasureCatalog.TREASURE_CHEST],
		"ports": [PortCatalog.PORT_QUAI, PortCatalog.PORT_QUAI_DE_PECHE, PortCatalog.PORT_PETIT_PORT],
		"entry_message": "Eaux sures - menaces faibles",
	},
	ZONE_WATCHED: {
		"id": ZONE_WATCHED,
		"name": "Zone surveillee",
		"level": 2,
		"description": "Patrouilles legeres et premiers brigantins.",
		"enemy_types": ["small_pirate", "brigantine"],
		"enemy_density": 0.8,
		"reward_multiplier": 1.15,
		"treasures": [TreasureCatalog.TREASURE_CHEST, TreasureCatalog.TREASURE_VAULT],
		"ports": [PortCatalog.PORT_POSTE_DE_GARDE, PortCatalog.PORT_PORT_MARCHAND],
		"entry_message": "Zone surveillee - vigilance conseillee",
	},
	ZONE_CONTESTED: {
		"id": ZONE_CONTESTED,
		"name": "Zone contestee",
		"level": 3,
		"description": "Route de combat plus dense, avec brigantins dominants.",
		"enemy_types": ["small_pirate", "brigantine", "heavy_patrol"],
		"enemy_density": 1.2,
		"reward_multiplier": 1.3,
		"treasures": [TreasureCatalog.TREASURE_VAULT, TreasureCatalog.TREASURE_CAVE],
		"ports": [PortCatalog.PORT_CRIQUE_CONTREBANDIERS, PortCatalog.PORT_GRAND_PORT],
		"entry_message": "Zone contestee - combats probables",
	},
	ZONE_HOSTILE: {
		"id": ZONE_HOSTILE,
		"name": "Zone hostile",
		"level": 4,
		"description": "Eaux dangereuses avec patrouilleurs lourds reguliers.",
		"enemy_types": ["brigantine", "heavy_patrol"],
		"enemy_density": 1.6,
		"reward_multiplier": 1.5,
		"treasures": [TreasureCatalog.TREASURE_CAVE, TreasureCatalog.TREASURE_ROYAL],
		"ports": [PortCatalog.PORT_FORTIN_FRONTIERE, PortCatalog.PORT_ARSENAL_NAVAL],
		"entry_message": "Zone hostile - preparez la flotte",
	},
	ZONE_DEADLY: {
		"id": ZONE_DEADLY,
		"name": "Zone mortelle",
		"level": 5,
		"description": "Secteur avance pour navire prepare et cargaison rentable.",
		"enemy_types": ["brigantine", "heavy_patrol"],
		"enemy_density": 2.0,
		"reward_multiplier": 1.8,
		"treasures": [TreasureCatalog.TREASURE_ROYAL, TreasureCatalog.TREASURE_IMPERIAL],
		"ports": [PortCatalog.PORT_PORT_TEMPETE, PortCatalog.PORT_CAPITALE_MARITIME],
		"entry_message": "Zone mortelle - risque tres eleve",
	},
	ZONE_LEGENDARY: {
		"id": ZONE_LEGENDARY,
		"name": "Territoire legendaire",
		"level": 6,
		"description": "Territoire futur pour expeditions rares.",
		"enemy_types": ["heavy_patrol"],
		"enemy_density": 2.0,
		"reward_multiplier": 2.2,
		"treasures": [TreasureCatalog.TREASURE_IMPERIAL, TreasureCatalog.TREASURE_MYTHIC],
		"ports": [PortCatalog.PORT_VIEUX_ROI, PortCatalog.PORT_LEGENDAIRE],
		"entry_message": "Territoire legendaire - fortune et peril",
	},
	ZONE_ABYSS: {
		"id": ZONE_ABYSS,
		"name": "Enfers des mers",
		"level": 7,
		"description": "Zone finale future, reservee aux capitaines les plus avances.",
		"enemy_types": ["heavy_patrol"],
		"enemy_density": 2.4,
		"reward_multiplier": 2.8,
		"treasures": [TreasureCatalog.TREASURE_MYTHIC],
		"ports": [PortCatalog.PORT_QUAI_ABYSSES, PortCatalog.PORT_SANCTUAIRE_PIRATE],
		"entry_message": "Enfers des mers - zone extreme",
	},
}

const LEGACY_ZONE_MAP := {
	LEGACY_ZONE_PORT: ZONE_SAFE,
	LEGACY_ZONE_ARCHIPELAGO: ZONE_WATCHED,
	LEGACY_ZONE_HOSTILE: ZONE_HOSTILE,
}


static func get_zone_ids() -> Array[String]:
	return ZONE_IDS.duplicate()


static func has_zone(zone_id: String) -> bool:
	return ZONES.has(normalize_zone_id(zone_id))


static func normalize_zone_id(zone_id_or_name: String) -> String:
	var raw_zone: String = zone_id_or_name.strip_edges()
	if raw_zone.is_empty():
		return ZONE_SAFE
	if ZONES.has(raw_zone):
		return raw_zone
	if LEGACY_ZONE_MAP.has(raw_zone):
		return String(LEGACY_ZONE_MAP[raw_zone])

	for zone_id in ZONE_IDS:
		var zone_data: Dictionary = ZONES[zone_id]
		var zone_name: String = String(zone_data.get("name", ""))
		if zone_name == raw_zone:
			return zone_id

	return ZONE_SAFE


static func get_zone(zone_id_or_name: String) -> Dictionary:
	var zone_id: String = normalize_zone_id(zone_id_or_name)
	var zone_data: Dictionary = ZONES[zone_id]
	return zone_data.duplicate(true)


static func get_zone_name(zone_id_or_name: String) -> String:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return String(zone_data.get("name", "Eaux sures"))


static func get_zone_level(zone_id_or_name: String) -> int:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return maxi(1, int(zone_data.get("level", 1)))


static func get_zone_description(zone_id_or_name: String) -> String:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return String(zone_data.get("description", ""))


static func get_enemy_density(zone_id_or_name: String) -> float:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return maxf(0.1, float(zone_data.get("enemy_density", 1.0)))


static func get_reward_multiplier(zone_id_or_name: String) -> float:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return maxf(1.0, float(zone_data.get("reward_multiplier", 1.0)))


static func get_entry_message(zone_id_or_name: String) -> String:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	return String(zone_data.get("entry_message", get_zone_name(zone_id_or_name)))


static func get_enemy_types(zone_id_or_name: String) -> Array[String]:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	var raw_types: Array = zone_data.get("enemy_types", [])
	var enemy_types: Array[String] = []
	for raw_type in raw_types:
		enemy_types.append(String(raw_type))

	return enemy_types


static func get_treasures(zone_id_or_name: String) -> Array[String]:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	var raw_treasures: Array = zone_data.get("treasures", [])
	var treasure_ids: Array[String] = []
	for raw_treasure in raw_treasures:
		treasure_ids.append(String(raw_treasure))

	return treasure_ids


static func get_ports(zone_id_or_name: String) -> Array[String]:
	var zone_data: Dictionary = get_zone(zone_id_or_name)
	var raw_ports: Array = zone_data.get("ports", [])
	var port_ids: Array[String] = []
	for raw_port in raw_ports:
		port_ids.append(String(raw_port))

	return port_ids


static func get_zone_summary_lines() -> Array[String]:
	var lines: Array[String] = []
	for zone_id in ZONE_IDS:
		lines.append(
			"%s - niv. %d - densite x%.2f - recompenses x%.2f"
			% [
				get_zone_name(zone_id),
				get_zone_level(zone_id),
				get_enemy_density(zone_id),
				get_reward_multiplier(zone_id),
			]
		)

	return lines
