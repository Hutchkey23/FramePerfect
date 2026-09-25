extends Resource
class_name LevelData

@export var level_id: String
@export var level_title: String
@export var medal_time: float = 999999.0
@export_file("*.tscn") var level_scene_path: String


func load_level_scene() -> PackedScene:
	if level_scene_path.is_empty():
		push_error("No level scene path set for: " + level_id)
		return null

	return load(level_scene_path) as PackedScene
