extends Node

const IS_DEMO: bool = false

var DEMO_WORLD = load("res://resources/world_data/demo_world.tres")

func get_demo_worlds() -> Array[WorldData]:
	return [DEMO_WORLD]

func get_main_marathon_id() -> String:
	if IS_DEMO:
		return "demo_world"

	return "world_01"
