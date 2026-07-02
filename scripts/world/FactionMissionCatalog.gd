class_name FactionMissionCatalog
extends RefCounted

const OBJECTIVE_DESTROY_SHIP: String = "destroy_ship"
const OBJECTIVE_DESTROY_PIRATE: String = "destroy_pirate"
const OBJECTIVE_DEFEAT_MARINE_CREATURE: String = "defeat_marine_creature"
const OBJECTIVE_TRADE_TRANSACTION: String = "trade_transaction"
const OBJECTIVE_TRADE_PROFIT: String = "trade_profit"
const OBJECTIVE_EXPLORE_SITE: String = "explore_site"
const OBJECTIVE_COLLECT_RARE_RESOURCE: String = "collect_rare_resource"

const MISSION_IDS: Array[String] = [
	"pirates_plunder_ships",
	"pirates_hidden_routes",
	"navy_secure_waters",
	"navy_protect_routes",
	"merchants_trade_run",
	"merchants_market_profit",
	"smugglers_rare_cargo",
	"smugglers_contested_cache",
	"abyss_hunt_creatures",
	"abyss_collect_relics",
]

const MISSION_IDS_BY_FACTION: Dictionary = {
	FactionCatalog.FACTION_PIRATES: ["pirates_plunder_ships", "pirates_hidden_routes"],
	FactionCatalog.FACTION_NAVY: ["navy_secure_waters", "navy_protect_routes"],
	FactionCatalog.FACTION_MERCHANTS: ["merchants_trade_run", "merchants_market_profit"],
	FactionCatalog.FACTION_SMUGGLERS: ["smugglers_rare_cargo", "smugglers_contested_cache"],
	FactionCatalog.FACTION_ABYSS_CULT: ["abyss_hunt_creatures", "abyss_collect_relics"],
}

const MISSIONS: Dictionary = {
	"pirates_plunder_ships": {
		"id": "pirates_plunder_ships",
		"faction_id": FactionCatalog.FACTION_PIRATES,
		"name": "Butin de bordee",
		"description": "Piller des navires pour renforcer la reputation pirate.",
		"objective_type": OBJECTIVE_DESTROY_SHIP,
		"objective_text": "Detruire 3 navires pirates ennemis",
		"target": 3,
		"recommended_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"difficulty": 2,
		"reward": {"gold": 140, "wood": 30, "renown": 20},
		"influence": {"gain_faction": FactionCatalog.FACTION_PIRATES, "gain": 4, "reduce_faction": FactionCatalog.FACTION_NAVY, "reduce": 2},
		"accept_text": "Les Pirates attendent du butin et des coques brisees.",
		"success_text": "Les prises renforcent la legende pirate.",
	},
	"pirates_hidden_routes": {
		"id": "pirates_hidden_routes",
		"faction_id": FactionCatalog.FACTION_PIRATES,
		"name": "Routes de pillage",
		"description": "Explorer des caches et reperer de nouvelles routes de raid.",
		"objective_type": OBJECTIVE_EXPLORE_SITE,
		"objective_text": "Explorer 2 sites",
		"target": 2,
		"recommended_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"difficulty": 2,
		"reward": {"gold": 90, "wood": 60, "renown": 15},
		"influence": {"gain_faction": FactionCatalog.FACTION_PIRATES, "gain": 3, "reduce_faction": FactionCatalog.FACTION_MERCHANTS, "reduce": 2},
		"accept_text": "Les Pirates veulent de nouvelles routes discretes.",
		"success_text": "Les routes de pillage sont mieux connues.",
	},
	"navy_secure_waters": {
		"id": "navy_secure_waters",
		"faction_id": FactionCatalog.FACTION_NAVY,
		"name": "Securiser les eaux",
		"description": "Traquer les pirates pour rendre une zone navigable.",
		"objective_type": OBJECTIVE_DESTROY_PIRATE,
		"objective_text": "Detruire 3 pirates",
		"target": 3,
		"recommended_zone": DangerZoneCatalog.ZONE_WATCHED,
		"difficulty": 2,
		"reward": {"gold": 120, "wood": 50, "renown": 25},
		"influence": {"gain_faction": FactionCatalog.FACTION_NAVY, "gain": 4, "reduce_faction": FactionCatalog.FACTION_PIRATES, "reduce": 3},
		"accept_text": "La Marine royale attend une zone plus sure.",
		"success_text": "Les eaux sont plus sures pour les convois.",
	},
	"navy_protect_routes": {
		"id": "navy_protect_routes",
		"faction_id": FactionCatalog.FACTION_NAVY,
		"name": "Routes protegees",
		"description": "Soutenir les routes marchandes en commerce actif.",
		"objective_type": OBJECTIVE_TRADE_TRANSACTION,
		"objective_text": "Faire 3 transactions commerciales",
		"target": 3,
		"recommended_zone": DangerZoneCatalog.ZONE_WATCHED,
		"difficulty": 1,
		"reward": {"gold": 90, "wood": 40, "renown": 15},
		"influence": {"gain_faction": FactionCatalog.FACTION_NAVY, "gain": 2, "reduce_faction": FactionCatalog.FACTION_PIRATES, "reduce": 2},
		"accept_text": "La Marine veut des routes marchandes actives.",
		"success_text": "Les routes sont mieux protegees.",
	},
	"merchants_trade_run": {
		"id": "merchants_trade_run",
		"faction_id": FactionCatalog.FACTION_MERCHANTS,
		"name": "Convoi marchand",
		"description": "Faire tourner le commerce local pour enrichir la Ligue.",
		"objective_type": OBJECTIVE_TRADE_TRANSACTION,
		"objective_text": "Faire 4 transactions commerciales",
		"target": 4,
		"recommended_zone": DangerZoneCatalog.ZONE_WATCHED,
		"difficulty": 1,
		"reward": {"gold": 130, "wood": 20, "renown": 15},
		"influence": {"gain_faction": FactionCatalog.FACTION_MERCHANTS, "gain": 4, "reduce_faction": FactionCatalog.FACTION_PIRATES, "reduce": 2},
		"accept_text": "La Ligue marchande attend des ventes regulieres.",
		"success_text": "Le commerce local reprend confiance.",
	},
	"merchants_market_profit": {
		"id": "merchants_market_profit",
		"faction_id": FactionCatalog.FACTION_MERCHANTS,
		"name": "Benefices de quai",
		"description": "Generer un benefice commercial visible.",
		"objective_type": OBJECTIVE_TRADE_PROFIT,
		"objective_text": "Gagner 180 or par vente de marchandises",
		"target": 180,
		"recommended_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"difficulty": 2,
		"reward": {"gold": 100, "wood": 40, "renown": 20},
		"influence": {"gain_faction": FactionCatalog.FACTION_MERCHANTS, "gain": 5, "reduce_faction": FactionCatalog.FACTION_SMUGGLERS, "reduce": 2},
		"accept_text": "La Ligue marchande veut des preuves de profit.",
		"success_text": "Les caisses de la Ligue sont pleines.",
	},
	"smugglers_rare_cargo": {
		"id": "smugglers_rare_cargo",
		"faction_id": FactionCatalog.FACTION_SMUGGLERS,
		"name": "Cargaison rare",
		"description": "Recuperer des ressources rares sans poser de questions.",
		"objective_type": OBJECTIVE_COLLECT_RARE_RESOURCE,
		"objective_text": "Recuperer 2 ressources rares de creatures",
		"target": 2,
		"recommended_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"difficulty": 2,
		"reward": {"gold": 130, "wood": 30, "renown": 20, "creature_resources": {MarineCreatureCatalog.RESOURCE_BLACK_PEARL: 1}},
		"influence": {"gain_faction": FactionCatalog.FACTION_SMUGGLERS, "gain": 4, "reduce_faction": FactionCatalog.FACTION_MERCHANTS, "reduce": 2},
		"accept_text": "Les Contrebandiers paient les trouvailles rares.",
		"success_text": "La cargaison rare alimente le reseau noir.",
	},
	"smugglers_contested_cache": {
		"id": "smugglers_contested_cache",
		"faction_id": FactionCatalog.FACTION_SMUGGLERS,
		"name": "Cache contestee",
		"description": "Explorer des sites pour ouvrir de nouveaux passages discrets.",
		"objective_type": OBJECTIVE_EXPLORE_SITE,
		"objective_text": "Explorer 2 sites",
		"target": 2,
		"recommended_zone": DangerZoneCatalog.ZONE_CONTESTED,
		"difficulty": 2,
		"reward": {"gold": 100, "wood": 50, "renown": 15},
		"influence": {"gain_faction": FactionCatalog.FACTION_SMUGGLERS, "gain": 4, "reduce_faction": FactionCatalog.FACTION_NAVY, "reduce": 2},
		"accept_text": "Les Contrebandiers cherchent des caches nouvelles.",
		"success_text": "Une cache supplementaire passe sous controle discret.",
	},
	"abyss_hunt_creatures": {
		"id": "abyss_hunt_creatures",
		"faction_id": FactionCatalog.FACTION_ABYSS_CULT,
		"name": "Offrande des profondeurs",
		"description": "Vaincre des creatures pour etudier leur force.",
		"objective_type": OBJECTIVE_DEFEAT_MARINE_CREATURE,
		"objective_text": "Vaincre 3 creatures marines",
		"target": 3,
		"recommended_zone": DangerZoneCatalog.ZONE_HOSTILE,
		"difficulty": 3,
		"reward": {"gold": 150, "wood": 0, "renown": 25, "map_fragments": 1},
		"influence": {"gain_faction": FactionCatalog.FACTION_ABYSS_CULT, "gain": 4, "reduce_faction": FactionCatalog.FACTION_NAVY, "reduce": 2},
		"accept_text": "Les Cultes abyssaux veulent observer la mer en colere.",
		"success_text": "Les murmures des profondeurs gagnent en force.",
	},
	"abyss_collect_relics": {
		"id": "abyss_collect_relics",
		"faction_id": FactionCatalog.FACTION_ABYSS_CULT,
		"name": "Ecailles de l'abime",
		"description": "Rapporter des ressources liees aux creatures dangereuses.",
		"objective_type": OBJECTIVE_COLLECT_RARE_RESOURCE,
		"objective_text": "Recuperer 2 ressources rares de creatures",
		"target": 2,
		"recommended_zone": DangerZoneCatalog.ZONE_HOSTILE,
		"difficulty": 3,
		"reward": {"gold": 120, "wood": 0, "renown": 25, "ancient_relics": 1},
		"influence": {"gain_faction": FactionCatalog.FACTION_ABYSS_CULT, "gain": 5, "reduce_faction": FactionCatalog.FACTION_MERCHANTS, "reduce": 2},
		"accept_text": "Les Cultes abyssaux cherchent des fragments de monstres.",
		"success_text": "Les reliques abyssales nourrissent le culte.",
	},
}


static func get_mission_ids() -> Array[String]:
	return MISSION_IDS.duplicate()


static func get_mission_ids_for_faction(faction_id: String) -> Array[String]:
	if MISSION_IDS_BY_FACTION.has(faction_id):
		return _get_string_array(MISSION_IDS_BY_FACTION[faction_id])

	var ids: Array[String] = []
	for mission_id in MISSION_IDS:
		if get_mission_faction_id(mission_id) == faction_id:
			ids.append(mission_id)

	return ids


static func has_mission(mission_id: String) -> bool:
	return MISSIONS.has(mission_id)


static func get_mission(mission_id: String) -> Dictionary:
	if not MISSIONS.has(mission_id):
		return {}

	var mission: Dictionary = MISSIONS[mission_id]
	return mission.duplicate(true)


static func get_mission_name(mission_id: String) -> String:
	var mission: Dictionary = get_mission(mission_id)
	return String(mission.get("name", "Mission de faction"))


static func get_mission_faction_id(mission_id: String) -> String:
	var mission: Dictionary = get_mission(mission_id)
	return String(mission.get("faction_id", ""))


static func get_objective_type(mission_id: String) -> String:
	var mission: Dictionary = get_mission(mission_id)
	return String(mission.get("objective_type", ""))


static func get_target(mission_id: String) -> int:
	var mission: Dictionary = get_mission(mission_id)
	return maxi(1, int(mission.get("target", 1)))


static func get_reward(mission_id: String) -> Dictionary:
	var mission: Dictionary = get_mission(mission_id)
	var reward: Dictionary = mission.get("reward", {})
	return reward.duplicate(true)


static func get_influence(mission_id: String) -> Dictionary:
	var mission: Dictionary = get_mission(mission_id)
	var influence: Dictionary = mission.get("influence", {})
	return influence.duplicate(true)


static func get_accept_text(mission_id: String) -> String:
	var mission: Dictionary = get_mission(mission_id)
	return String(mission.get("accept_text", "Mission de faction acceptee."))


static func get_success_text(mission_id: String) -> String:
	var mission: Dictionary = get_mission(mission_id)
	return String(mission.get("success_text", "Mission de faction terminee."))


static func get_objective_label(objective_type: String) -> String:
	match objective_type:
		OBJECTIVE_DESTROY_SHIP:
			return "navires detruits"
		OBJECTIVE_DESTROY_PIRATE:
			return "pirates detruits"
		OBJECTIVE_DEFEAT_MARINE_CREATURE:
			return "creatures vaincues"
		OBJECTIVE_TRADE_TRANSACTION:
			return "transactions"
		OBJECTIVE_TRADE_PROFIT:
			return "or de commerce"
		OBJECTIVE_EXPLORE_SITE:
			return "sites explores"
		OBJECTIVE_COLLECT_RARE_RESOURCE:
			return "ressources rares"

	return "objectifs"


static func _get_string_array(raw_value: Variant) -> Array[String]:
	var values: Array[String] = []
	if not (raw_value is Array):
		return values

	for raw_item in raw_value:
		var item: String = String(raw_item)
		if not item.is_empty():
			values.append(item)

	return values
