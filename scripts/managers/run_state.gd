extends Node

var start_world_data: WorldData = null
var start_level_data: LevelData = null

var has_pending_level_select: bool = false

var has_pending_marathon := false
var pending_marathon_data: MarathonData = null


func select_level(world_data: WorldData, level_data: LevelData) -> void:
	start_world_data = world_data
	start_level_data = level_data
	has_pending_level_select = true


func clear_pending_selection() -> void:
	has_pending_level_select = false
	start_world_data = null
	start_level_data = null


func set_pending_marathon(marathon_data: MarathonData) -> void:
	has_pending_marathon = true
	pending_marathon_data = marathon_data


func clear_pending_marathon() -> void:
	has_pending_marathon = false
	pending_marathon_data = null
