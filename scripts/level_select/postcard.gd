extends Control

@export var postcard_image: Texture
@export var world_number: int
@export var world_title: String

@onready var world_number_label: Label = $BackgroundPanel/VBoxContainer/WorldNumberLabelMarginContainer/WorldNumberLabel
@onready var world_title_label: Label = $BackgroundPanel/VBoxContainer/WorldTitleLabelMarginContainer/WorldTitleLabel
@onready var postcard_texture: TextureRect = $BackgroundPanel/PostcardTexture

func _ready() -> void:
	if postcard_image:
		postcard_texture.texture = postcard_image
		
	world_number_label.text = "WORLD " + str(world_number)
	
	world_title_label.text = world_title
