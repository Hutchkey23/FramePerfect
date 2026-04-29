extends Control

@export var postcard_front_image: Texture
@export var postcard_back_image: Texture
@export var world_number: int
@export var world_title: String
@export_enum("GREEN", "YELLOW", "BLUE", "PURPLE") var font_color = 0

# Front
@onready var postcard_front_texture: TextureRect = $Front/PostcardFrontTexture
@onready var world_number_label: Label = $Front/VBoxContainer/WorldNumberLabelMarginContainer/WorldNumberLabel
@onready var world_title_label: Label = $Front/VBoxContainer/WorldTitleLabelMarginContainer/WorldTitleLabel


# Back
@onready var postcard_back_texture: TextureRect = $Back/PostcardBackTexture
@onready var level_title_label: Label = $Back/VBoxContainer/MarginContainer/LevelTitleLabel
@onready var left_arrow: Label = $Back/VBoxContainer/HBoxContainer/LeftArrow
@onready var level_number_label: Label = $Back/VBoxContainer/HBoxContainer/LevelNumberLabel
@onready var right_arrow: Label = $Back/VBoxContainer/HBoxContainer/RightArrow
@onready var best_time_text_label: Label = $Back/VBoxContainer/MarginContainer2/BestTimeTextLabel
@onready var best_time_label: Label = $Back/VBoxContainer/BestTimeAndMedalContainer/BestTimeLabel

var labels: Array[Label]

func _ready() -> void:
	labels = [
		world_number_label,
		world_title_label,
		level_title_label,
		left_arrow,
		level_number_label,
		right_arrow,
		best_time_text_label,
		best_time_label
	]
	if postcard_front_image:
		postcard_front_texture.texture = postcard_front_image
	
	if postcard_back_image:
		postcard_back_texture.texture = postcard_back_image
		
	world_number_label.text = "WORLD " + str(world_number)
	
	world_title_label.text = world_title
	
	set_font_color(font_color)

func set_font_color(color_index: int):
	var color_hex: String = "#FFFFFF"
	match color_index:
		0: # Green
			color_hex = "#008751"
		1: # Yellow
			color_hex = "#f8a019"
		2: # Blue
			color_hex = "#194c88"
		3: # Purple
			color_hex = "#5a4da3"
	
	for label in labels:
		label.add_theme_color_override("font_color", color_hex)
