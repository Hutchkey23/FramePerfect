extends Node

var start_world_index: int = 0
var start_level_index: int = 0

var has_pending_level_select: bool = false
var has_pending_marathon := false
var pending_marathon_data: MarathonData = null

func set_pending_marathon(marathon_data: MarathonData) -> void:
	has_pending_marathon = true
	pending_marathon_data = marathon_data

func clear_pending_marathon() -> void:
	has_pending_marathon = false
	pending_marathon_data = null

func select_level(world_index: int, level_index: int) -> void:
	start_world_index = world_index
	start_level_index = level_index
	has_pending_level_select = true


func clear_pending_selection() -> void:
	has_pending_level_select = false
