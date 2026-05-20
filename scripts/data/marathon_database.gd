extends Node

const PEACEFUL_PLAINS_MARATHON = preload("uid://dnauec61r8nf")
const SCORCHED_SANDS_MARATHON = preload("uid://nli7jt4xwhwt")
const FROSTED_FRONTIER_MARATHON = preload("uid://chdk8s824pi8n")
const GALACTIC_GATEWAYS_MARATHON = preload("uid://bcno8v7tfu1gc")
const ALL_WORLDS_MARATHON = preload("uid://dkaotj3i5an5r")

var worlds: Array[MarathonData] = [
	PEACEFUL_PLAINS_MARATHON,
	SCORCHED_SANDS_MARATHON,
	FROSTED_FRONTIER_MARATHON,
	GALACTIC_GATEWAYS_MARATHON
]

func setup(new_worlds: Array[MarathonData]) -> void:
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
