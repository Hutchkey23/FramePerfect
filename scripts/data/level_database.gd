extends Node

const PEACEFUL_PLAINS = preload("uid://uotkih62v0dd")
const SCORCHED_SANDS = preload("uid://dv7uy4up300c1")
const FROSTED_FRONTIER = preload("uid://ct5yadc3b6fc6")
const GALACTIC_GATEWAYS = preload("uid://ec3th64jjhhr")


var worlds: Array[WorldData] = [
	PEACEFUL_PLAINS,
	SCORCHED_SANDS,
	FROSTED_FRONTIER,
	GALACTIC_GATEWAYS
]

func setup(new_worlds: Array[WorldData]) -> void:
	worlds = new_worlds


func get_level_data(level_id: String) -> LevelData:
	for world in worlds:
		for level in world.levels:
			if level.level_id == level_id:
				return level
	
	return null


func get_medal_time(level_id: String) -> float:
	var level := get_level_data(level_id)
	if level == null:
		return 999999.0
	
	return level.medal_time


func get_display_name(level_id: String) -> String:
	var level := get_level_data(level_id)
	if level == null:
		return level_id
	
	return level.level_title
