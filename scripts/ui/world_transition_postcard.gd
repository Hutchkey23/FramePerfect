extends Control
class_name WorldTransitionPostcard

@export var world_data: WorldData

@onready var postcard_front_texture: TextureRect = $Front/PostcardFrontTexture
@onready var world_number_label: Label = $Front/VBoxContainer/WorldNumberLabelMarginContainer/WorldNumberLabel
@onready var world_title_label: Label = $Front/VBoxContainer/WorldTitleLabelMarginContainer/WorldTitleLabel

var labels: Array[Label]

var postcard_tween: Tween

func _ready() -> void:
	labels = [
		world_number_label,
		world_title_label
	]

func setup(data: WorldData) -> void:
	world_data = data

	world_number_label.text = "WORLD " + str(data.world_number)
	world_title_label.text = data.world_title
	postcard_front_texture.texture = data.front_image
	set_font_color(data.font_color)
	
func set_font_color(chosen_color: Color):
	for label in labels:
		label.add_theme_color_override("font_color", chosen_color)

func change_to_delivered() -> void:
	world_title_label.text = "DELIVERED!"
