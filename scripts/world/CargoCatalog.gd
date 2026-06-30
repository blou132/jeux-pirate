class_name CargoCatalog
extends RefCounted

const GOOD_RUM := "rum"
const GOOD_SPICES := "spices"
const GOOD_CLOTH := "cloth"
const GOOD_ORE := "ore"
const GOOD_PEARLS := "pearls"

const TRADE_GOOD_IDS: Array[String] = [
	GOOD_RUM,
	GOOD_SPICES,
	GOOD_CLOTH,
	GOOD_ORE,
	GOOD_PEARLS,
]

const TRADE_GOODS := {
	"rum": {
		"id": "rum",
		"name": "Rhum",
		"weight": 10,
		"buy_price": 60,
		"sell_price": 45,
	},
	"spices": {
		"id": "spices",
		"name": "Epices",
		"weight": 5,
		"buy_price": 90,
		"sell_price": 65,
	},
	"cloth": {
		"id": "cloth",
		"name": "Tissu",
		"weight": 8,
		"buy_price": 45,
		"sell_price": 30,
	},
	"ore": {
		"id": "ore",
		"name": "Minerai",
		"weight": 15,
		"buy_price": 80,
		"sell_price": 55,
	},
	"pearls": {
		"id": "pearls",
		"name": "Perles",
		"weight": 3,
		"buy_price": 160,
		"sell_price": 120,
	},
}


static func get_trade_good_ids() -> Array[String]:
	return TRADE_GOOD_IDS.duplicate()


static func has_good(item_id: String) -> bool:
	return TRADE_GOODS.has(item_id)


static func get_good(item_id: String) -> Dictionary:
	if not TRADE_GOODS.has(item_id):
		return {}

	var good: Dictionary = TRADE_GOODS[item_id]
	return good.duplicate(true)


static func get_good_name(item_id: String) -> String:
	var good: Dictionary = get_good(item_id)
	return String(good.get("name", item_id))


static func get_good_weight(item_id: String) -> int:
	var good: Dictionary = get_good(item_id)
	return maxi(0, int(good.get("weight", 0)))


static func get_buy_price(item_id: String) -> int:
	var good: Dictionary = get_good(item_id)
	return maxi(0, int(good.get("buy_price", 0)))


static func get_sell_price(item_id: String) -> int:
	var good: Dictionary = get_good(item_id)
	return maxi(0, int(good.get("sell_price", 0)))


static func get_trade_good_lines() -> Array[String]:
	var lines: Array[String] = []
	for item_id in TRADE_GOOD_IDS:
		lines.append(
			"%s - poids %d - achat %d or - vente %d or"
			% [
				get_good_name(item_id),
				get_good_weight(item_id),
				get_buy_price(item_id),
				get_sell_price(item_id),
			]
		)

	return lines
