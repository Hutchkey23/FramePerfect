extends Node

var start_world_index: int = 0
var start_level_index: int = 0

var has_pending_level_select: bool = false


func select_level(world_index: int, level_index: int) -> void:
	start_world_index = world_index
	start_level_index = level_index
	has_pending_level_select = true


func clear_pending_selection() -> void:
	has_pending_level_select = false
