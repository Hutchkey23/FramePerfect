extends Node2D
class_name Results

@onready var time_label: RichTextLabel = $Results/Control/TimeLabel
@onready var completion_message: RichTextLabel = $Results/Control/CompletionMessage
@onready var final_message: RichTextLabel = $Results/Control/FinalMessage
@onready var sfx_pool: Node2D = $SFXPool

var game_manager_reference: GameManager

var results_tween: Tween

var new_best_or_medal: bool = false

const final_message_new_best_or_medal_choices: Array[String] = [
	"Holy smokes!",
	"Great job!",
	"You are speedy!",
	"New record!",
	"Lightning fast!",
	"Mail master!",
	"That was clean!",
	"Incredible run!",
	"Too fast!",
	"Unstoppable!",
	"Speed demon!",
	"Perfect routing!",
	"You nailed it!",
	"What a run!",
	"Full speed ahead!",
	"Look at you go!",
	"Marathon machine!",
	"You are cooking!",
	"Absolute cinema!",
	"Mail delivered!",
	"Now that's fast!",
	"Top tier delivery!",
]

const final_message_other_choices: Array[String] = [
	"You got this!",
	"Keep at it!",
	"Try again?",
	"Another attempt?",
	"So close!",
	"One more run!",
	"You can do it!",
	"Keep delivering!",
	"Don't give up!",
	"Almost there!",
	"Back in the mail!",
	"Run it back!",
	"Shake it off!",
	"You'll get it!",
	"Keep the mail moving!",
	"Just a little faster!",
	"The mailbox awaits!",
	"Keep pushing!",
	"You're improving!",
	"Stay speedy!",
	"Keep the momentum!",
	"You're getting there!",
]

############ AUDIO HANDLING ############
const NEW_BEST_SFX = preload("uid://bbxn1phuna1rs")
const NEW_BEST_VOLUME: float = -3.0
const NEW_BEST_PITCH_RANGE: Vector2 = Vector2(1.0, 1.0)

const GOAL_UNLOCK_SFX = preload("uid://c4xw6nwf22trw")
const GOAL_UNLOCK_VOLUME: float = -3.0
const GOAL_UNLOCK_PITCH_RANGE: Vector2 = Vector2(0.8, 1.0)

const POP_SFX = preload("uid://bpce1xgwwn4rn")
const POP_VOLUME: float = -3.0
const POP_PITCH_RANGE: Vector2 = Vector2(0.8, 0.8)
########################################

func _ready() -> void:
	time_label.visible = false
	completion_message.visible = false
	final_message.visible = false
	
	game_manager_reference = get_tree().get_first_node_in_group("game_manager")

func setup_marathon_results(results_data: Dictionary) -> void:
	print(results_data)
	setup_completion_message(results_data)
	await get_tree().process_frame
	
	setup_final_message()
	time_label.text = format_time(results_data.clear_time)
	game_manager_reference.enable_pause()

func setup_completion_message(results_data: Dictionary) -> void:
	if results_data.earned_medal and results_data.first_medal:
		completion_message.text = "[wave][rainbow]MEDAL EARNED![/rainbow][/wave]"
		new_best_or_medal = true
	elif results_data.new_best and not results_data.first_medal:
		completion_message.text = "[wave][rainbow]NEW BEST![/rainbow][/wave]"
		new_best_or_medal = true
	elif not results_data.earned_medal:
		var time_needed = results_data.missed_medal_by
		completion_message.text = "[color=00ff00]%.2fs[/color] FROM MEDAL!" % time_needed
	elif results_data.earned_medal and not results_data.new_best:
		var time_needed = results_data.missed_new_best_by
		completion_message.text = "[color=00ff00]%.2fs[/color] FROM NEW BEST!" % time_needed

func setup_final_message() -> void:
	var phrase: String
	if new_best_or_medal:
		phrase = final_message_new_best_or_medal_choices.pick_random()
	else:
		phrase = final_message_other_choices.pick_random()
	
	final_message.text = "[wave]" + phrase + "[/wave]"

func show_results() -> void:
	await get_tree().create_timer(1.5).timeout
	
	if results_tween:
		results_tween.kill()

	results_tween = create_tween()
	
	pop_in_label(time_label)
	results_tween.tween_callback(play_sfx.bind(GOAL_UNLOCK_SFX, GOAL_UNLOCK_VOLUME - 4.0, Vector2(0.6, 0.6)))
	
	results_tween.tween_interval(1.0)
	if new_best_or_medal:
		pass
	else:
		pass
	results_tween.tween_callback(pop_in_label.bind(completion_message))
	
	if new_best_or_medal:
		results_tween.tween_callback(play_sfx.bind(NEW_BEST_SFX, NEW_BEST_VOLUME, NEW_BEST_PITCH_RANGE))
	else:
		results_tween.tween_callback(play_sfx.bind(GOAL_UNLOCK_SFX, GOAL_UNLOCK_VOLUME - 4.0, Vector2(0.6, 0.6)))
	
	results_tween.tween_interval(1.5)
	await results_tween.finished
	play_sfx(POP_SFX, POP_VOLUME, POP_PITCH_RANGE)
	final_message.visible = true


func pop_in_label(label: Control) -> void:
	label.visible = true
	label.modulate.a = 0.0
	label.scale = Vector2(0.6, 0.6)
	label.pivot_offset = label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(label, "modulate:a", 1.0, 0.12)

	tween.tween_property(label, "scale", Vector2(1.18, 1.18), 0.14)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.chain().tween_property(label, "scale", Vector2.ONE, 0.08)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func format_time(time: float) -> String:
	if time < 60.0:
		return "%.2f" % time
	else:
		var minutes := int(time / 60.0)
		var seconds := fmod(time, 60.0)

		return "%d:%05.2f" % [minutes, seconds]

####### AUDIO HANDLING ########
func play_sfx(sfx: AudioStream, volume_db: float = 0.0, pitch_range: Vector2 = Vector2(0.95, 1.05)):
	for audio_player: AudioStreamPlayer2D in sfx_pool.get_children():
		if not audio_player.playing:
			audio_player.volume_db = volume_db
			audio_player.stream = sfx
			audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
			audio_player.play()
			return
###############################
