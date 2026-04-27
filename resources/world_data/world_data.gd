extends Resource
class_name WorldData

@export var world_id: String
@export var world_title: String
@export var world_intro_text: String
@export var cutscene_scene: PackedScene
@export var background_music: Array[AudioStream]
@export var levels: Array[LevelData]
