extends Node

const IS_DEMO: bool = true

var DEMO_WORLD = load("res://resources/world_data/demo_world.tres")

func get_demo_worlds() -> Array[WorldData]:
	return [DEMO_WORLD]
