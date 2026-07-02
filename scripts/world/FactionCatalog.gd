class_name FactionCatalog
extends RefCounted

const FACTION_NEUTRAL: String = "neutral"
const FACTION_PIRATES: String = "pirates"
const FACTION_NAVY: String = "navy"
const FACTION_MERCHANTS: String = "merchants"
const FACTION_SMUGGLERS: String = "smugglers"
const FACTION_ABYSS_CULT: String = "abyss_cult"

const ALL_FACTIONS: Array[String] = [
	FACTION_PIRATES,
	FACTION_NAVY,
	FACTION_MERCHANTS,
	FACTION_SMUGGLERS,
	FACTION_ABYSS_CULT,
]

const PLAYER_FACTIONS: Array[String] = [
	FACTION_NEUTRAL,
	FACTION_PIRATES,
	FACTION_NAVY,
	FACTION_MERCHANTS,
	FACTION_SMUGGLERS,
	FACTION_ABYSS_CULT,
]

const NEUTRAL_PLAYER_FACTION: Dictionary = {
	"name": "Neutre",
	"hud_label": "Neutre",
	"description": "Aucune allegiance officielle. Le capitaine reste libre de ses choix.",
	"style": "independance, flexibilite",
	"base_relation": "neutre",
	"player_bonus": "Aucun bonus, aucune penalite.",
	"join_message": "Vous etes redevenu neutre",
	"ship_combat_gold_multiplier": 1.00,
	"pirate_renown_multiplier": 1.00,
	"trade_profit_multiplier": 1.00,
	"rare_creature_resource_multiplier": 1.00,
	"dangerous_creature_reward_multiplier": 1.00,
	"territory_bonus_faction": "",
	"territory_bonus_amount": 0,
}

const FACTIONS: Dictionary = {
	FACTION_PIRATES: {
		"name": "Pirates",
		"hud_label": "Pirates",
		"description": "Pillage, chaos et combat naval.",
		"style": "pillage, chaos, combat",
		"base_relation": "hostile",
		"player_bonus": "+10 % or sur les combats contre navires ennemis.",
		"join_message": "Vous avez rejoint les Pirates",
		"ship_combat_gold_multiplier": 1.10,
		"pirate_renown_multiplier": 1.00,
		"trade_profit_multiplier": 1.00,
		"rare_creature_resource_multiplier": 1.00,
		"dangerous_creature_reward_multiplier": 1.00,
		"territory_bonus_faction": FACTION_PIRATES,
		"territory_bonus_amount": 1,
		"pirate_spawn_multiplier": 1.25,
		"marine_spawn_multiplier": 1.05,
		"dangerous_creature_multiplier": 1.05,
		"trade_sell_multiplier": 0.95,
		"repair_cost_multiplier": 1.12,
		"rare_reward_multiplier": 1.00,
		"port_safety": "instable",
		"color_label": "rouge",
		"dominance_message": "Les Pirates renforcent leur controle sur %s",
		"port_effect": "Pirates dominants : commerce tendu, reparations plus cheres.",
	},
	FACTION_NAVY: {
		"name": "Marine royale",
		"hud_label": "Marine",
		"description": "Ordre, securite et chasse aux pirates.",
		"style": "ordre, securite, chasse aux pirates",
		"base_relation": "neutre",
		"player_bonus": "+10 % renom contre les pirates et influence marine accrue.",
		"join_message": "Vous avez prete serment a la Marine royale",
		"ship_combat_gold_multiplier": 1.00,
		"pirate_renown_multiplier": 1.10,
		"trade_profit_multiplier": 1.00,
		"rare_creature_resource_multiplier": 1.00,
		"dangerous_creature_reward_multiplier": 1.00,
		"territory_bonus_faction": FACTION_NAVY,
		"territory_bonus_amount": 1,
		"pirate_spawn_multiplier": 0.75,
		"marine_spawn_multiplier": 0.90,
		"dangerous_creature_multiplier": 0.90,
		"trade_sell_multiplier": 1.00,
		"repair_cost_multiplier": 0.90,
		"rare_reward_multiplier": 1.00,
		"port_safety": "protege",
		"color_label": "bleu",
		"dominance_message": "La Marine royale securise %s",
		"port_effect": "Marine dominante : port plus sur, reparations moins cheres.",
	},
	FACTION_MERCHANTS: {
		"name": "Ligue marchande",
		"hud_label": "Marchands",
		"description": "Commerce, routes maritimes et richesse.",
		"style": "commerce, routes maritimes, richesse",
		"base_relation": "amicale",
		"player_bonus": "+5 % benefice commerce et influence marchande accrue.",
		"join_message": "Vous soutenez desormais la Ligue marchande",
		"ship_combat_gold_multiplier": 1.00,
		"pirate_renown_multiplier": 1.00,
		"trade_profit_multiplier": 1.05,
		"rare_creature_resource_multiplier": 1.00,
		"dangerous_creature_reward_multiplier": 1.00,
		"territory_bonus_faction": FACTION_MERCHANTS,
		"territory_bonus_amount": 1,
		"pirate_spawn_multiplier": 0.85,
		"marine_spawn_multiplier": 0.95,
		"dangerous_creature_multiplier": 0.92,
		"trade_sell_multiplier": 1.10,
		"repair_cost_multiplier": 1.00,
		"rare_reward_multiplier": 1.00,
		"port_safety": "stable",
		"color_label": "or",
		"dominance_message": "La Ligue marchande stabilise %s",
		"port_effect": "Ligue marchande dominante : prix de vente meilleurs.",
	},
	FACTION_SMUGGLERS: {
		"name": "Contrebandiers",
		"hud_label": "Contrebande",
		"description": "Marche noir, ports caches et objets rares.",
		"style": "marche noir, ports caches, objets rares",
		"base_relation": "mefiante",
		"player_bonus": "+10 % ressources rares de creatures marines.",
		"join_message": "Vous travaillez avec les Contrebandiers",
		"ship_combat_gold_multiplier": 1.00,
		"pirate_renown_multiplier": 1.00,
		"trade_profit_multiplier": 1.00,
		"rare_creature_resource_multiplier": 1.10,
		"dangerous_creature_reward_multiplier": 1.00,
		"territory_bonus_faction": FACTION_SMUGGLERS,
		"territory_bonus_amount": 1,
		"pirate_spawn_multiplier": 1.05,
		"marine_spawn_multiplier": 1.00,
		"dangerous_creature_multiplier": 1.00,
		"trade_sell_multiplier": 1.05,
		"repair_cost_multiplier": 1.05,
		"rare_reward_multiplier": 1.20,
		"port_safety": "mixte",
		"color_label": "violet",
		"dominance_message": "Les Contrebandiers etendent leurs reseaux dans %s",
		"port_effect": "Contrebandiers dominants : marche noir actif, ressources rares mieux valorisees.",
	},
	FACTION_ABYSS_CULT: {
		"name": "Cultes abyssaux",
		"hud_label": "Abysses",
		"description": "Monstres marins, zones maudites et tresors mythiques.",
		"style": "monstres marins, zones maudites, tresors mythiques",
		"base_relation": "hostile",
		"player_bonus": "+10 % or et ressources sur creatures marines dangereuses.",
		"join_message": "Vous avez accepte les murmures des Cultes abyssaux",
		"ship_combat_gold_multiplier": 1.00,
		"pirate_renown_multiplier": 1.00,
		"trade_profit_multiplier": 1.00,
		"rare_creature_resource_multiplier": 1.00,
		"dangerous_creature_reward_multiplier": 1.10,
		"territory_bonus_faction": FACTION_ABYSS_CULT,
		"territory_bonus_amount": 1,
		"pirate_spawn_multiplier": 0.85,
		"marine_spawn_multiplier": 1.25,
		"dangerous_creature_multiplier": 1.25,
		"trade_sell_multiplier": 0.90,
		"repair_cost_multiplier": 1.10,
		"rare_reward_multiplier": 1.15,
		"port_safety": "maudit",
		"color_label": "sombre",
		"dominance_message": "Les Cultes abyssaux corrompent %s",
		"port_effect": "Cultes abyssaux dominants : commerce instable, creatures plus presentes.",
	},
}


static func get_faction_ids() -> Array[String]:
	return ALL_FACTIONS.duplicate()


static func get_player_faction_ids() -> Array[String]:
	return PLAYER_FACTIONS.duplicate()


static func has_faction(faction_id: String) -> bool:
	return FACTIONS.has(faction_id)


static func has_player_faction(faction_id: String) -> bool:
	return faction_id == FACTION_NEUTRAL or has_faction(faction_id)


static func normalize_player_faction_id(faction_id: String) -> String:
	if has_player_faction(faction_id):
		return faction_id

	return FACTION_NEUTRAL


static func get_faction(faction_id: String) -> Dictionary:
	if not has_faction(faction_id):
		return {}

	var faction: Dictionary = FACTIONS[faction_id]
	return faction.duplicate(true)


static func get_player_faction(faction_id: String) -> Dictionary:
	var normalized_id: String = normalize_player_faction_id(faction_id)
	if normalized_id == FACTION_NEUTRAL:
		return NEUTRAL_PLAYER_FACTION.duplicate(true)

	return get_faction(normalized_id)


static func get_faction_name(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("name", faction_id))


static func get_player_faction_name(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("name", "Neutre"))


static func get_hud_label(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("hud_label", get_faction_name(faction_id)))


static func get_player_hud_label(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("hud_label", get_player_faction_name(faction_id)))


static func get_description(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("description", ""))


static func get_player_description(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("description", ""))


static func get_player_bonus_summary(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("player_bonus", "Aucun bonus, aucune penalite."))


static func get_player_join_message(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("join_message", "Allegeance mise a jour"))


static func get_player_bonus_modifier(faction_id: String, key: String, default_value: float = 1.0) -> float:
	var faction: Dictionary = get_player_faction(faction_id)
	return float(faction.get(key, default_value))


static func get_player_territory_bonus_faction(faction_id: String) -> String:
	var faction: Dictionary = get_player_faction(faction_id)
	return String(faction.get("territory_bonus_faction", ""))


static func get_player_territory_bonus_amount(faction_id: String) -> int:
	var faction: Dictionary = get_player_faction(faction_id)
	return maxi(0, int(faction.get("territory_bonus_amount", 0)))


static func get_style(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("style", ""))


static func get_base_relation(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("base_relation", "neutre"))


static func get_color_label(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("color_label", "neutre"))


static func get_port_safety_label(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("port_safety", "inconnu"))


static func get_port_effect_text(faction_id: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	return String(faction.get("port_effect", "Controle territorial sans effet special."))


static func get_dominance_message(faction_id: String, zone_name: String) -> String:
	var faction: Dictionary = get_faction(faction_id)
	var template: String = String(faction.get("dominance_message", "%s controle %s"))
	return template % zone_name


static func get_pirate_spawn_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "pirate_spawn_multiplier", 1.0)


static func get_marine_spawn_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "marine_spawn_multiplier", 1.0)


static func get_dangerous_creature_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "dangerous_creature_multiplier", 1.0)


static func get_trade_sell_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "trade_sell_multiplier", 1.0)


static func get_repair_cost_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "repair_cost_multiplier", 1.0)


static func get_rare_reward_multiplier(faction_id: String) -> float:
	return _get_float_modifier(faction_id, "rare_reward_multiplier", 1.0)


static func _get_float_modifier(faction_id: String, key: String, default_value: float) -> float:
	var faction: Dictionary = get_faction(faction_id)
	return float(faction.get(key, default_value))
