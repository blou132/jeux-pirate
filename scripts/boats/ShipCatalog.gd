class_name ShipCatalog
extends RefCounted

const SHIP_BARQUE := "barque"
const SHIP_CHALOUPE := "chaloupe"
const SHIP_SLOOP := "sloop"
const SHIP_GOELLETTE := "goelette"

const UPGRADE_HULL := "hull"
const UPGRADE_SAILS := "sails"
const UPGRADE_CANNONS := "cannons"

const STARTING_SHIP_ID := SHIP_BARQUE

const PLAYER_SHIP_IDS: Array[String] = [
	SHIP_BARQUE,
	SHIP_CHALOUPE,
	SHIP_SLOOP,
	SHIP_GOELLETTE,
]

const PLAYER_SHIPS := {
	"barque": {
		"id": "barque",
		"name": "Barque",
		"max_health": 100,
		"max_speed": 7.0,
		"reverse_speed": 5.0,
		"turn_speed": 1.85,
		"maneuverability": "élevée",
		"storage": 100,
		"cannons": 1,
		"cannon_damage": 25,
		"role": "débutant / exploration côtière",
		"cost": {"gold": 0, "wood": 0, "map_fragments": 0},
		"upgrade_limits": {"hull": 3, "sails": 3, "cannons": 3},
	},
	"chaloupe": {
		"id": "chaloupe",
		"name": "Chaloupe",
		"max_health": 125,
		"max_speed": 8.0,
		"reverse_speed": 5.4,
		"turn_speed": 2.1,
		"maneuverability": "très élevée",
		"storage": 130,
		"cannons": 2,
		"cannon_damage": 28,
		"role": "rapide / missions légères",
		"cost": {"gold": 400, "wood": 120, "map_fragments": 0},
		"upgrade_limits": {"hull": 4, "sails": 4, "cannons": 4},
	},
	"sloop": {
		"id": "sloop",
		"name": "Sloop",
		"max_health": 175,
		"max_speed": 7.5,
		"reverse_speed": 5.2,
		"turn_speed": 1.5,
		"maneuverability": "moyenne",
		"storage": 180,
		"cannons": 3,
		"cannon_damage": 34,
		"role": "polyvalent",
		"cost": {"gold": 900, "wood": 250, "map_fragments": 0},
		"upgrade_limits": {"hull": 5, "sails": 5, "cannons": 5},
	},
	"goelette": {
		"id": "goelette",
		"name": "Goélette",
		"max_health": 220,
		"max_speed": 8.5,
		"reverse_speed": 5.8,
		"turn_speed": 1.25,
		"maneuverability": "moyenne-faible",
		"storage": 260,
		"cannons": 4,
		"cannon_damage": 38,
		"role": "commerce / escorte",
		"cost": {"gold": 1600, "wood": 400, "map_fragments": 1},
		"upgrade_limits": {"hull": 6, "sails": 6, "cannons": 6},
	},
}

const SHIP_HIERARCHY: Array[Dictionary] = [
	{"id": "radeau", "name": "Radeau", "status": "à venir", "upgrade_max": 2},
	{"id": "barque", "name": "Barque", "status": "jouable", "upgrade_max": 3},
	{"id": "chaloupe", "name": "Chaloupe", "status": "jouable", "upgrade_max": 4},
	{"id": "sloop", "name": "Sloop", "status": "jouable", "upgrade_max": 5},
	{"id": "goelette", "name": "Goélette", "status": "jouable", "upgrade_max": 6},
	{"id": "brick", "name": "Brick", "status": "à venir", "upgrade_max": 7},
	{"id": "fregate", "name": "Frégate", "status": "à venir", "upgrade_max": 8},
	{"id": "galion", "name": "Galion", "status": "à venir", "upgrade_max": 9},
	{"id": "vaisseau_ligne", "name": "Vaisseau de ligne", "status": "à venir", "upgrade_max": 10},
	{"id": "navire_legendaire", "name": "Navire légendaire", "status": "à venir", "upgrade_max": 12},
]


static func get_player_ship_ids() -> Array[String]:
	return PLAYER_SHIP_IDS.duplicate()


static func has_ship(ship_id: String) -> bool:
	return PLAYER_SHIPS.has(ship_id)


static func get_ship(ship_id: String) -> Dictionary:
	if not PLAYER_SHIPS.has(ship_id):
		ship_id = STARTING_SHIP_ID

	var ship: Dictionary = PLAYER_SHIPS[ship_id]
	return ship.duplicate(true)


static func get_ship_name(ship_id: String) -> String:
	var ship := get_ship(ship_id)
	return String(ship.get("name", "Barque"))


static func get_ship_cost(ship_id: String) -> Dictionary:
	var ship := get_ship(ship_id)
	var cost: Dictionary = ship.get("cost", {})
	return cost.duplicate()


static func get_upgrade_limits(ship_id: String) -> Dictionary:
	var ship := get_ship(ship_id)
	var limits: Dictionary = ship.get("upgrade_limits", {})
	return limits.duplicate()


static func get_upgrade_limit(ship_id: String, upgrade_id: String) -> int:
	var limits := get_upgrade_limits(ship_id)
	return int(limits.get(upgrade_id, 3))


static func is_free_ship(ship_id: String) -> bool:
	var cost := get_ship_cost(ship_id)
	return int(cost.get("gold", 0)) <= 0 and int(cost.get("wood", 0)) <= 0 and int(cost.get("map_fragments", 0)) <= 0


static func format_cost(ship_id: String) -> String:
	if is_free_ship(ship_id):
		return "navire de départ"

	var cost := get_ship_cost(ship_id)
	var parts: Array[String] = []
	var gold_cost: int = int(cost.get("gold", 0))
	var wood_cost: int = int(cost.get("wood", 0))
	var fragment_cost: int = int(cost.get("map_fragments", 0))

	if gold_cost > 0:
		parts.append("%d or" % gold_cost)
	if wood_cost > 0:
		parts.append("%d bois" % wood_cost)
	if fragment_cost > 0:
		parts.append("%d fragment" % fragment_cost)

	return ", ".join(parts)


static func get_ship_stat_lines(ship_id: String) -> Array[String]:
	var ship := get_ship(ship_id)
	return [
		"%s — %s" % [String(ship.get("name", "Navire")), String(ship.get("role", ""))],
		"PV : %d" % int(ship.get("max_health", 0)),
		"Vitesse : %.1f" % float(ship.get("max_speed", 0.0)),
		"Maniabilité : %s" % String(ship.get("maneuverability", "")),
		"Stockage : %d" % int(ship.get("storage", 0)),
		"Canons : %d" % int(ship.get("cannons", 0)),
		"Améliorations : coque %d, voiles %d, canons %d" % [
			get_upgrade_limit(ship_id, UPGRADE_HULL),
			get_upgrade_limit(ship_id, UPGRADE_SAILS),
			get_upgrade_limit(ship_id, UPGRADE_CANNONS),
		],
		"Coût : %s" % format_cost(ship_id),
	]


static func get_hierarchy_entries() -> Array[Dictionary]:
	return SHIP_HIERARCHY.duplicate(true)
