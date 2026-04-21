extends Node2D
class_name Goal

@onready var completion_label: RichTextLabel = $CompletionLabel
@onready var new_best_label: RichTextLabel = $NewBestLabel

var completion_words := [
	"Nice!",
	"Rad!",
	"Clean!",
	"Slick!",
	"Smooth!",
	"Great!",
	"Sweet!",
	"Sharp!",
	"Crisp!",
	"Solid!",
	"Tubular!",
	"Clutch!",
	"Snappy!",
	"Quick!",
	"Fast!",
	"Speedy!",
	"Boom!",
	"Nailed it!",
	"Let's go!",
	"Breezy!",
	"Sharp work!",
	"Well done!",
	"Too clean!",
	"On point!",
	"Beautiful!",
	"Elite!",
	"Prime!"
]

func _ready() -> void:
	completion_label.visible = false
	new_best_label.visible = false

func show_completion_label() -> void:
	var random_word = completion_words.pick_random()
	completion_label.text = "[wave]" + random_word.to_upper() + "[/wave]"
	completion_label.visible = true

func hide_completion_label() -> void:
	completion_label.visible = false
