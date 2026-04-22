extends Node2D
class_name Goal

@onready var completion_label: RichTextLabel = $CompletionLabel
@onready var new_best_label: RichTextLabel = $NewBestLabel
@onready var flag_pivot: Node2D = $FlagPivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprite: Sprite2D = $Sprite2D



const NORMAL_GOAL_SCALE : Vector2 = Vector2(0.5, 0.5)
const MAX_DEGREE_ROTATION : float = 10

var initial_rotation_degrees : float

var stamps_remaining: int = 0
var pop_tween : Tween
var goal_reached : bool = false
var time: float = 0.0
var completion_words := [
	"Delivered!",
	"Sent!",
	"Boomtastic!",
	"Boomshakalaka!",
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
	initial_rotation_degrees = rotation_degrees
	completion_label.visible = false
	new_best_label.visible = false

func _process(delta: float) -> void:
	if not goal_reached:
		return
	
	time += delta
	
	var rotation_offset = sin(5.0 * time) * MAX_DEGREE_ROTATION
	rotation_degrees = initial_rotation_degrees + rotation_offset

func show_completion_label() -> void:
	var random_word = completion_words.pick_random()
	completion_label.text = "[wave]" + random_word.to_upper() + "[/wave]"
	completion_label.visible = true

func retry_level() -> void:
	animation_player.stop()
	flag_pivot.rotation_degrees = 180.0
	completion_label.visible = false
	goal_reached = false
	rotation_degrees = initial_rotation_degrees
	time = 0.0

func goal_reached_animation() -> void:
	if pop_tween:
		pop_tween.kill()
	
	show_completion_label()
	animation_player.play("goal_animation")
	await animation_player.animation_finished
	goal_reached = true

func setup_stamps() -> void:
	for stamp: Stamp in get_tree().get_nodes_in_group("stamps"):
		stamp.collected.connect(on_stamp_collected)

func on_stamp_collected(stamp: Stamp) -> void:
	stamp.queue_free()
	stamps_remaining -= 1
	check_if_goal_available()

func check_if_goal_available() -> void:
	if stamps_remaining > 0:
		modulate = Color(0.5, 0.5, 0.5)
	else:
		activate_goal()

func activate_goal() -> void:
	if pop_tween:
		pop_tween.kill()

	scale = Vector2.ONE
	rotation_degrees = 0.0
	modulate = Color.WHITE

	pop_tween = create_tween()
	pop_tween.set_parallel(true)

	# Quick squash/stretch pop
	pop_tween.tween_property(self, "scale", Vector2(1.6, 0.6), 0.07) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

	# Tiny rotation punch
	pop_tween.tween_property(self, "rotation_degrees", -8.0, 0.07) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	pop_tween = create_tween()
	pop_tween.set_parallel(true)

	# Settle back with a little overshoot
	pop_tween.tween_property(self, "scale", Vector2(0.88, 1.18), 0.09) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(self, "rotation_degrees", 5.0, 0.09) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	pop_tween = create_tween()
	pop_tween.set_parallel(true)

	pop_tween.tween_property(self, "scale", Vector2.ONE, 0.14) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(self, "rotation_degrees", 0.0, 0.14) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
