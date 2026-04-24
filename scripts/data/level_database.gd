extends Node

const LEVEL_DATA : Dictionary = {
	"level_001": { "display_name": "getting started",  "medal_time": 1.50 },
	"level_002": { "display_name": "hoppin' around",  "medal_time": 2.00 },
	"level_003": { "display_name": "collect postage",  "medal_time": 3.00 },
	"level_004": { "display_name": "the wave",  "medal_time": 3.00 },
	"level_005": { "display_name": "Level 5",  "medal_time": 18.00 },

	"level_006": { "display_name": "?",  "medal_time": 13.50 },
	"level_007": { "display_name": "Level 7",  "medal_time": 15.50 },
	"level_008": { "display_name": "boomerang",  "medal_time": 6.00 },
	"level_009": { "display_name": "Level 9",  "medal_time": 17.00 },
	"level_010": { "display_name": "chain dash", "medal_time": 3.00 },

	"level_011": { "display_name": "it's all timing", "medal_time": 5.00 },
	"level_012": { "display_name": "Level 12", "medal_time": 16.50 },
	"level_013": { "display_name": "Level 13", "medal_time": 12.00 },
	"level_014": { "display_name": "Level 14", "medal_time": 18.50 },
	"level_015": { "display_name": "Level 15", "medal_time": 21.00 },

	"level_016": { "display_name": "Level 16", "medal_time": 15.00 },
	"level_017": { "display_name": "Level 17", "medal_time": 17.50 },
	"level_018": { "display_name": "like magic", "medal_time": 5.00},
	"level_019": { "display_name": "Level 19", "medal_time": 19.50 },
	"level_020": { "display_name": "steady", "medal_time": 10.00 }
}

func has_level(level_id: String) -> bool:
	return LEVEL_DATA.has(level_id)

func get_medal_time(level_id: String) -> float:
	if not LEVEL_DATA.has(level_id):
		return 999999.0
	return LEVEL_DATA[level_id].medal_time

func get_display_name(level_id: String) -> String:
	if not LEVEL_DATA.has(level_id):
		return level_id
	
	return LEVEL_DATA[level_id].display_name

func level_has_medal(level_id: String, best_time: float) -> bool:
	return best_time <= get_medal_time(level_id)
