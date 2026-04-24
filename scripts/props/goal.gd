extends Node2D
class_name Goal

@onready var completion_label: RichTextLabel = $CompletionLabel
@onready var new_best_or_medal_label: RichTextLabel = $NewBestOrMedalLabel
@onready var flag_pivot: Node2D = $FlagPivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var medal_sprite: Sprite2D = $GoalSprite/MedalSprite


const NORMAL_GOAL_SCALE : Vector2 = Vector2(0.5, 0.5)
const MAX_DEGREE_ROTATION : float = 10

var level_id : String = ""

var initial_rotation_degrees : float

var stamps_remaining: int = 0
var pop_tween : Tween
var goal_reached : bool = false
var time: float = 0.0

### COMPLETION WORDS ###
var medal_words := [
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
	"Prime!",
	"Wombo Combo!",
]
var close_words := [
	"So close!",
	"Almost!",
	"Right there!",
	"Just missed!",
	"Nearly!",
	"Keep pushing!",
	"You got this!",
	"One more run!",
	"That was fast!",
	"Close call!",
	"Right on the edge!",
	"Again!",
	"Just a bit more!",
	"Almost nailed it!",
	"That was quick!",
	"Nearly perfect!",
	"Just off!",
	"That’s the pace!",
]
var far_words := [
	"Keep going!",
	"Stay with it!",
	"Warming up!",
	"Getting there!",
	"Find the flow!",
	"Feel it out!",
	"You need to lock in!",
	"Keep at it!",
	"Run it back!",
	"Let’s go again!",
	"Dial it in!",
	"Keep pushing!",
	"Step it up!",
	"Get in the zone!",
	"Focus up!",
	"Try again!",
	"Keep moving!",
	"You’re learning!",
	"Don’t stop now!"
]
########################


func _ready() -> void:
	initial_rotation_degrees = rotation_degrees
	completion_label.visible = false
	new_best_or_medal_label.visible = false
	new_best_or_medal_label.pivot_offset = new_best_or_medal_label.size / 2
	
	if SaveManager.player_has_medal(level_id):
		show_medal()
	

func _process(delta: float) -> void:
	if not goal_reached:
		return
	
	time += delta
	
	var rotation_offset = sin(5.0 * time) * MAX_DEGREE_ROTATION
	rotation_degrees = initial_rotation_degrees + rotation_offset

func show_medal() -> void:
	medal_sprite.visible = true

func get_medal_message(result: Dictionary) -> String:
	if result["earned_medal_this_run"]:
		return "[rainbow][wave]MEDAL EARNED![/wave][/rainbow]"
	
	var time_needed: float = result["missed_medal_by"]
	return "[wave][color=00ff00]%.2fs[/color] FROM MEDAL![/wave]" % time_needed

func get_new_best_message(result: Dictionary) -> String:
	if result["new_best"]:
		return "[rainbow][wave]NEW BEST![/wave][/rainbow]"
	
	var time_needed: float = result["missed_new_best_by"]
	return "[wave][color=00ff00]%.2fs[/color] FROM NEW BEST![/wave]" % time_needed

func show_completion_label(result: Dictionary) -> void:
	var random_word: String
	
	if result.earned_medal_this_run:
		random_word = medal_words.pick_random()
	
	elif result.missed_medal_by < 1.50:
		random_word = close_words.pick_random()
	
	else:
		random_word = far_words.pick_random()
	
	completion_label.text = "[wave]" + random_word.to_upper() + "[/wave]"
	completion_label.visible = true

func retry_level() -> void:
	animation_player.stop()
	flag_pivot.rotation_degrees = 180.0
	completion_label.visible = false
	new_best_or_medal_label.visible = false
	goal_reached = false
	rotation_degrees = initial_rotation_degrees
	time = 0.0

func show_level_complete_result(result: Dictionary) -> void:
	show_completion_label(result)
	
	await goal_reached_animation()
	
	# Show new best only if medal has been earned and player sets high score
	if result.earned_medal and result.medal_already_achieved:
		var new_best_message = get_new_best_message(result)
		new_best_or_medal_label.text = new_best_message
	
	# If player has not earned a medal, show time save needed for medal
	else:
		var medal_message = get_medal_message(result)
		new_best_or_medal_label.text = medal_message
	
	show_new_best_or_medal_label(result)
	
	# Check if player earned medal this run
	if result.earned_medal_this_run and not result.medal_already_achieved:
		await medal_animation()
		await get_tree().create_timer(0.35).timeout
	
	goal_reached = true

func show_new_best_or_medal_label(result) -> void:
	new_best_or_medal_label.visible = true
	
	if (result.new_best and result.medal_already_achieved) or (result.earned_medal and not result.medal_already_achieved):
		new_best_or_medal_label.scale = Vector2(1.4, 1.2)
		new_best_or_medal_label.rotation_degrees = randf_range(-30, 30)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(new_best_or_medal_label, "scale", Vector2(0.9, 0.7), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_best_or_medal_label, "rotation_degrees", -new_best_or_medal_label.rotation_degrees, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.chain()
		tween.tween_property(new_best_or_medal_label, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_best_or_medal_label, "rotation_degrees", 0.0, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	else:
		pass

func goal_reached_animation() -> void:
	if pop_tween:
		pop_tween.kill()
	
	animation_player.play("goal_animation")
	await animation_player.animation_finished
	
func medal_animation() -> void:
	var tween = create_tween()
	medal_sprite.visible = true
	tween.set_parallel(true)
	tween.tween_property(medal_sprite, "rotation_degrees", randf_range(-30, 30), 0.18).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(medal_sprite, "scale", Vector2(2.5, 3.0), 0.18).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_property(medal_sprite, "rotation_degrees", 0.0, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(medal_sprite, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

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
