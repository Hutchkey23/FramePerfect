extends Resource
class_name MarathonData

@export var marathon_id: String
@export var display_name: String
@export var world_number: int
@export var worlds: Array[WorldData] = []
@export var medal_time: float = 999999.0

@export_group("Level Select")
@export var front_image: Texture2D
@export var back_image: Texture2D
@export var font_color: Color
@export var background_texture: Texture2D

func get_level_ids() -> Array[String]:
	var level_ids: Array[String] = []

	for world in worlds:
		for level in world.levels:
			level_ids.append(level.level_id)

	return level_ids
