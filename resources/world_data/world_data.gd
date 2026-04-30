extends Resource
class_name WorldData

@export var world_id: String
@export var world_title: String
@export var world_number: int
@export var world_intro_text: String
@export var cutscene_scene: PackedScene
@export var background_music: Array[AudioStream]
@export var levels: Array[LevelData]

@export_group("Level Select")
@export var front_image: Texture2D
@export var back_image: Texture2D
@export var font_color: Color
