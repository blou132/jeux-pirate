extends RefCounted
class_name PortCatalog

const SERVICE_REPAIR := "repair"
const SERVICE_FLEET := "fleet"
const SERVICE_UPGRADES := "upgrades"
const SERVICE_SHIPYARD := "shipyard"
const SERVICE_TRADE := "trade"
const SERVICE_MISSIONS := "missions"
const SERVICE_STATUS := "status"

const PORT_QUAI := "starter_quay"
const PORT_QUAI_DE_PECHE := "fisher_quay"
const PORT_PETIT_PORT := "petit_port"
const PORT_POSTE_DE_GARDE := "watch_post"
const PORT_PORT_MARCHAND := "merchant_port"
const PORT_CRIQUE_CONTREBANDIERS := "smuggler_cove"
const PORT_GRAND_PORT := "great_port"
const PORT_FORTIN_FRONTIERE := "frontier_fort"
const PORT_ARSENAL_NAVAL := "naval_arsenal"
const PORT_PORT_TEMPETE := "storm_harbor"
const PORT_CAPITALE_MARITIME := "capitale_maritime"
const PORT_VIEUX_ROI := "old_king_port"
const PORT_LEGENDAIRE := "port_legendaire"
const PORT_QUAI_ABYSSES := "abyss_black_dock"
const PORT_SANCTUAIRE_PIRATE := "sanctuaire_pirate"

const STARTING_PORT_ID := PORT_QUAI

const PORT_IDS: Array[String] = [
	PORT_QUAI,
	PORT_QUAI_DE_PECHE,
	PORT_PETIT_PORT,
	PORT_POSTE_DE_GARDE,
	PORT_PORT_MARCHAND,
	PORT_CRIQUE_CONTREBANDIERS,
	PORT_GRAND_PORT,
	PORT_FORTIN_FRONTIERE,
	PORT_ARSENAL_NAVAL,
	PORT_PORT_TEMPETE,
	PORT_CAPITALE_MARITIME,
	PORT_VIEUX_ROI,
	PORT_LEGENDAIRE,
	PORT_QUAI_ABYSSES,
	PORT_SANCTUAIRE_PIRATE,
]

const DANGER_ZONES: Array[String] = [
	"Eaux sures",
	"Zone surveillee",
	"Zone contestee",
	"Zone hostile",
	"Zone mortelle",
	"Territoire legendaire",
	"Enfers des mers",
]

const PORTS := {
	"starter_quay": {
		"id": "starter_quay",
		"name": "Quai du Pavillon",
		"level": 1,
		"category": "Quai",
		"danger_zone": "Eaux sures",
		"world_port": true,
		"services": ["repair", "trade", "missions", "status"],
		"trade_level": 1,
		"repair_level": 1,
		"shipyard_level": 0,
		"ships": ["barque"],
		"goods": ["rum", "cloth"],
		"missions": ["pirate_hunt", "return_to_port"],
	},
	"fisher_quay": {
		"id": "fisher_quay",
		"name": "Quai des Filets",
		"level": 1,
		"category": "Quai",
		"danger_zone": "Eaux sures",
		"services": ["repair", "trade", "missions", "status"],
		"trade_level": 1,
		"repair_level": 1,
		"shipyard_level": 0,
		"ships": ["barque"],
		"goods": ["rum", "cloth"],
		"missions": ["return_to_port"],
	},
	"petit_port": {
		"id": "petit_port",
		"name": "Petit port du Pavillon",
		"level": 2,
		"category": "Petit port",
		"danger_zone": "Eaux sures",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 2,
		"repair_level": 2,
		"shipyard_level": 1,
		"ships": ["barque", "chaloupe"],
		"goods": ["rum", "cloth", "spices"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"watch_post": {
		"id": "watch_post",
		"name": "Poste de garde de Clairevigie",
		"level": 2,
		"category": "Petit port",
		"danger_zone": "Zone surveillee",
		"services": ["repair", "fleet", "trade", "missions", "status"],
		"trade_level": 2,
		"repair_level": 2,
		"shipyard_level": 0,
		"ships": ["barque", "chaloupe"],
		"goods": ["rum", "cloth", "spices"],
		"missions": ["pirate_hunt", "return_to_port"],
	},
	"merchant_port": {
		"id": "merchant_port",
		"name": "Port marchand des Alizes",
		"level": 3,
		"category": "Port marchand",
		"danger_zone": "Zone surveillee",
		"world_port": true,
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 3,
		"repair_level": 2,
		"shipyard_level": 2,
		"ships": ["barque", "chaloupe", "sloop"],
		"goods": ["rum", "spices", "cloth", "ore"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"smuggler_cove": {
		"id": "smuggler_cove",
		"name": "Crique des Contrebandiers",
		"level": 3,
		"category": "Port marchand",
		"danger_zone": "Zone contestee",
		"services": ["repair", "fleet", "trade", "missions", "status"],
		"trade_level": 3,
		"repair_level": 2,
		"shipyard_level": 0,
		"ships": ["barque", "chaloupe", "sloop"],
		"goods": ["rum", "spices", "ore"],
		"missions": ["pirate_hunt", "first_map_fragment", "return_to_port"],
	},
	"great_port": {
		"id": "great_port",
		"name": "Grand port de Briselame",
		"level": 4,
		"category": "Grand port",
		"danger_zone": "Zone contestee",
		"world_port": true,
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 4,
		"repair_level": 3,
		"shipyard_level": 3,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"frontier_fort": {
		"id": "frontier_fort",
		"name": "Fortin de Frontiere",
		"level": 4,
		"category": "Grand port",
		"danger_zone": "Zone hostile",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 3,
		"repair_level": 4,
		"shipyard_level": 3,
		"ships": ["barque", "chaloupe", "sloop"],
		"goods": ["rum", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic"],
	},
	"naval_arsenal": {
		"id": "naval_arsenal",
		"name": "Arsenal naval de Ferhoule",
		"level": 5,
		"category": "Arsenal naval",
		"danger_zone": "Zone hostile",
		"world_port": true,
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 4,
		"repair_level": 4,
		"shipyard_level": 4,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"storm_harbor": {
		"id": "storm_harbor",
		"name": "Havre des Tempetes",
		"level": 5,
		"category": "Arsenal naval",
		"danger_zone": "Zone mortelle",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 4,
		"repair_level": 5,
		"shipyard_level": 4,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic"],
	},
	"capitale_maritime": {
		"id": "capitale_maritime",
		"name": "Capitale maritime d'Azur",
		"level": 6,
		"category": "Capitale maritime",
		"danger_zone": "Zone mortelle",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 5,
		"repair_level": 5,
		"shipyard_level": 5,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"old_king_port": {
		"id": "old_king_port",
		"name": "Port du Vieux Roi",
		"level": 6,
		"category": "Capitale maritime",
		"danger_zone": "Territoire legendaire",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 5,
		"repair_level": 6,
		"shipyard_level": 5,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic"],
	},
	"port_legendaire": {
		"id": "port_legendaire",
		"name": "Port legendaire de Brume-Or",
		"level": 7,
		"category": "Port legendaire",
		"danger_zone": "Territoire legendaire",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 6,
		"repair_level": 6,
		"shipyard_level": 6,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
	"abyss_black_dock": {
		"id": "abyss_black_dock",
		"name": "Quai noir des Abysses",
		"level": 7,
		"category": "Port legendaire",
		"danger_zone": "Enfers des mers",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 6,
		"repair_level": 7,
		"shipyard_level": 6,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["spices", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic"],
	},
	"sanctuaire_pirate": {
		"id": "sanctuaire_pirate",
		"name": "Sanctuaire pirate des Abysses",
		"level": 8,
		"category": "Sanctuaire pirate",
		"danger_zone": "Enfers des mers",
		"services": ["repair", "fleet", "upgrades", "shipyard", "trade", "missions", "status"],
		"trade_level": 7,
		"repair_level": 7,
		"shipyard_level": 7,
		"ships": ["barque", "chaloupe", "sloop", "goelette"],
		"goods": ["rum", "spices", "cloth", "ore", "pearls"],
		"missions": ["pirate_hunt", "first_map_fragment", "ancient_relic", "return_to_port"],
	},
}


static func get_port_ids() -> Array[String]:
	return PORT_IDS.duplicate()


static func get_danger_zones() -> Array[String]:
	return DANGER_ZONES.duplicate()


static func get_ports_for_danger_zone(danger_zone: String) -> Array[String]:
	var ids: Array[String] = []
	for port_id in PORT_IDS:
		if get_port_danger_zone(port_id) == danger_zone:
			ids.append(port_id)

	return ids


static func get_ports_by_level(min_level: int, max_level: int) -> Array[String]:
	var ids: Array[String] = []
	var from_level: int = maxi(1, min_level)
	var to_level: int = maxi(from_level, max_level)
	for port_id in PORT_IDS:
		var port_level: int = get_port_level(port_id)
		if port_level >= from_level and port_level <= to_level:
			ids.append(port_id)

	return ids


static func get_world_port_ids() -> Array[String]:
	var ids: Array[String] = []
	for port_id in PORT_IDS:
		if is_world_port(port_id):
			ids.append(port_id)

	return ids


static func has_port(port_id: String) -> bool:
	return PORTS.has(port_id)


static func get_port(port_id: String) -> Dictionary:
	if not PORTS.has(port_id):
		port_id = STARTING_PORT_ID

	var port: Dictionary = PORTS[port_id]
	return port.duplicate(true)


static func get_port_name(port_id: String) -> String:
	var port: Dictionary = get_port(port_id)
	return String(port.get("name", "Port"))


static func get_port_category(port_id: String) -> String:
	var port: Dictionary = get_port(port_id)
	return String(port.get("category", "Port"))


static func get_port_danger_zone(port_id: String) -> String:
	var port: Dictionary = get_port(port_id)
	return String(port.get("danger_zone", "Eaux sures"))


static func get_port_level(port_id: String) -> int:
	var port: Dictionary = get_port(port_id)
	return maxi(1, int(port.get("level", 1)))


static func is_world_port(port_id: String) -> bool:
	var port: Dictionary = get_port(port_id)
	return bool(port.get("world_port", false))


static func get_trade_level(port_id: String) -> int:
	var port: Dictionary = get_port(port_id)
	return maxi(0, int(port.get("trade_level", 0)))


static func get_repair_level(port_id: String) -> int:
	var port: Dictionary = get_port(port_id)
	return maxi(0, int(port.get("repair_level", 0)))


static func get_shipyard_level(port_id: String) -> int:
	var port: Dictionary = get_port(port_id)
	return maxi(0, int(port.get("shipyard_level", 0)))


static func get_port_services(port_id: String) -> Array[String]:
	var port: Dictionary = get_port(port_id)
	return _get_string_array(port.get("services", []))


static func has_service(port_id: String, service_id: String) -> bool:
	return get_port_services(port_id).has(service_id)


static func get_port_ship_ids(port_id: String) -> Array[String]:
	var port: Dictionary = get_port(port_id)
	return _get_string_array(port.get("ships", []))


static func has_ship(port_id: String, ship_id: String) -> bool:
	return get_port_ship_ids(port_id).has(ship_id)


static func get_port_trade_good_ids(port_id: String) -> Array[String]:
	var port: Dictionary = get_port(port_id)
	return _get_string_array(port.get("goods", []))


static func has_trade_good(port_id: String, item_id: String) -> bool:
	return get_port_trade_good_ids(port_id).has(item_id)


static func get_port_mission_ids(port_id: String) -> Array[String]:
	var port: Dictionary = get_port(port_id)
	return _get_string_array(port.get("missions", []))


static func has_mission(port_id: String, quest_id: String) -> bool:
	return get_port_mission_ids(port_id).has(quest_id)


static func get_service_names(port_id: String) -> Array[String]:
	var names: Array[String] = []
	for service_id in get_port_services(port_id):
		names.append(_get_service_name(service_id))

	return names


static func get_port_row_text(port_id: String) -> String:
	return "%s - niv. %d - %s" % [
		get_port_name(port_id),
		get_port_level(port_id),
		get_port_danger_zone(port_id),
	]


static func get_port_details_text(port_id: String) -> String:
	return "%s\nCategorie : %s\nZone de danger : %s\nServices : %s\nCommerce niv. %d - Reparation niv. %d - Chantier niv. %d" % [
		get_port_name(port_id),
		get_port_category(port_id),
		get_port_danger_zone(port_id),
		", ".join(get_service_names(port_id)),
		get_trade_level(port_id),
		get_repair_level(port_id),
		get_shipyard_level(port_id),
	]


static func _get_service_name(service_id: String) -> String:
	match service_id:
		SERVICE_REPAIR:
			return "Reparations"
		SERVICE_FLEET:
			return "Flotte"
		SERVICE_UPGRADES:
			return "Ameliorations"
		SERVICE_SHIPYARD:
			return "Chantier naval"
		SERVICE_TRADE:
			return "Commerce"
		SERVICE_MISSIONS:
			return "Missions"
		SERVICE_STATUS:
			return "Statut pirate"

	return service_id


static func _get_string_array(raw_value: Variant) -> Array[String]:
	var values: Array[String] = []
	if not (raw_value is Array):
		return values

	for raw_item in raw_value:
		var item: String = String(raw_item)
		if not item.is_empty():
			values.append(item)

	return values
