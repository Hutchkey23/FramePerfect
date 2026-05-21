extends Node2D
class_name GameManager

enum GameMode {
	NORMAL,
	MARATHON,
}

const MARATHON_RESULTS : Dictionary = {
	"world_01": preload("uid://cqt1tw0cqi6jv"),
	"world_02": preload("uid://cd6nplujadiq"),
	"world_03": preload("uid://41v0qhg5e2v6"),
	"world_04": preload("uid://3wi43o16qj4m"),
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_container: Node2D = $LevelContainer
@onready var transition: CanvasLayer = $Transition
@onready var level_title_label: RichTextLabel = $Transition/LevelTitleLabel
@onready var pause_screen: PauseMenu = $PauseLayer/PauseScreen
@onready var world_transition: WorldTransition = $WorldTransition
@onready var sfx_pool: Node2D = $SFXPool

const TRANSITION_LENGTH: float = 1.25

@export var worlds: Array[WorldData]

var game_mode: GameMode = GameMode.NORMAL

###### MARATHON MODE ######
var current_marathon_data: MarathonData = null

var marathon_id: String = ""
var marathon_level_ids: Array[String] = []
var marathon_current_index: int = 0

var marathon_time: float = 0.0
var marathon_timer_running: bool = false
var marathon_deaths: int = 0
var marathon_level_attempts: Dictionary = {}

var marathon_finished: bool = false
###########################

var current_world_index: int = 0
var current_level_index: int = 0
var current_level_id: String
var current_world_level_names: Array = []
var level_controller_reference: LevelController

var should_show_initial_world_transition: bool = false

var game_pausable: bool = false
var is_paused: bool = false

var first_level_loaded_title: String = ""

############## AUDIO HANDLING ##############
const DELIVERED_SFX = preload("uid://cag0lu35jttel")
const DELIVERED_VOLUME: float = -6.0
const DELIVERED_PITCH_RANGE: Vector2 = Vector2(1.0, 1.0)
############################################

func _ready() -> void:
	if RunState.has_pending_marathon:
		setup_marathon_from_run_state()
	else:
		setup_normal_from_run_state()

	await start_run()

func setup_normal_from_run_state() -> void:
	game_mode = GameMode.NORMAL

	LevelDatabase.setup(worlds)

	if RunState.has_pending_level_select:
		current_world_index = RunState.start_world_index
		current_level_index = RunState.start_level_index
		should_show_initial_world_transition = false
		RunState.clear_pending_selection()
	else:
		current_world_index = 0
		current_level_index = 0
		should_show_initial_world_transition = true

	current_world_level_names = get_world_level_names(current_world_index)
	set_level_title_label_text(current_level_index)

func setup_marathon_from_run_state() -> void:
	var data := RunState.pending_marathon_data
	RunState.clear_pending_marathon()

	if data == null:
		push_error("Missing MarathonData.")
		setup_normal_from_run_state()
		return

	setup_marathon_from_data(data)

func pause_marathon_timer() -> void:
	if game_mode != GameMode.MARATHON:
		return
	
	marathon_timer_running = false

func _process(delta: float) -> void:
	if game_mode == GameMode.MARATHON and marathon_timer_running:
		marathon_time += delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused or not game_pausable:
			return
		pause_game()

func start_marathon_timer() -> void:
	if game_mode != GameMode.MARATHON:
		return
	
	marathon_timer_running = true

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	pause_screen.visible = true


func _on_pause_screen_resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	pause_screen.visible = false


func _on_pause_screen_go_to_main_menu() -> void:
	is_paused = false
	get_tree().paused = false
	
	animation_player.play("global_transition_out")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")


func _on_pause_screen_retry_level() -> void:
	is_paused = false
	get_tree().paused = false
	pause_screen.visible = false
	
	if level_controller_reference:
		level_controller_reference.retry_level()


func get_world_level_names(world_index: int) -> Array:
	var level_names := []
	var current_world := worlds[world_index]

	for level: LevelData in current_world.levels:
		level_names.append(level.level_title)

	return level_names


func set_level_title_label_text(level_index: int) -> void:
	var level_title = current_world_level_names[level_index]
	
	if first_level_loaded_title == "":
		first_level_loaded_title = level_title
	
	level_title_label.text = level_title


func start_run() -> void:
	var bg_music_array = worlds[current_world_index].background_music
	print(bg_music_array)
	if bg_music_array.size() > 0:
		BGMManager.play_world_playlist(bg_music_array, false)
	
	if should_show_initial_world_transition:
		transition.visible = false
		world_transition.play_initial_transition(worlds[current_world_index])
		animation_player.play("global_transition_in")
		await animation_player.animation_finished
		await get_tree().create_timer(1.5).timeout
		load_level()
		transition.visible = true
		await transition_out()
		world_transition.visible = false
	
	else:
		load_level()
		animation_player.play("global_transition_in")
		await animation_player.animation_finished

	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	await transition_in()

	if level_controller_reference:
		level_controller_reference.enter_intro_state()

	game_pausable = true


func transition_in() -> void:
	transition.visible = true
	animation_player.play("transition_in")
	await animation_player.animation_finished
	transition.visible = false


func transition_out() -> void:
	transition.visible = true
	animation_player.play("transition_out")
	await animation_player.animation_finished


func instantiate_current_level() -> Node:
	set_level_title_label_text(current_level_index)

	var level_data := get_current_level_data()
	if level_data == null or level_data.level_scene == null:
		push_error("Missing LevelData or level_scene.")
		return null

	current_level_id = level_data.level_id

	var new_level := level_data.level_scene.instantiate()
	level_container.add_child(new_level)

	return new_level


func load_level() -> void:
	var new_level := instantiate_current_level()
	if new_level == null:
		return

	setup_loaded_level(new_level)


func setup_loaded_level(loaded_level: Node) -> void:
	get_level_controller_reference(loaded_level)

	if level_controller_reference:
		level_controller_reference.setup_level(current_level_id)


func get_level_controller_reference(loaded_level: Node = null) -> void:
	if loaded_level == null:
		if level_container.get_child_count() == 0:
			return
		loaded_level = level_container.get_child(0)

	level_controller_reference = loaded_level.get_tree().get_first_node_in_group("level_controller")

	if level_controller_reference == null:
		return

	if not level_controller_reference.load_next_level.is_connected(load_next_level):
		level_controller_reference.load_next_level.connect(load_next_level)

	if not level_controller_reference.level_completed.is_connected(disable_pause):
		level_controller_reference.level_completed.connect(disable_pause)

	if not level_controller_reference.level_failed.is_connected(disable_pause):
		level_controller_reference.level_failed.connect(disable_pause)

	if not level_controller_reference.level_started.is_connected(enable_pause):
		level_controller_reference.level_started.connect(enable_pause)

	if not level_controller_reference.retry_level_requested.is_connected(retry_level):
		level_controller_reference.retry_level_requested.connect(retry_level)

func register_marathon_attempt_started() -> void:
	if game_mode != GameMode.MARATHON:
		return

	var level_id := marathon_level_ids[marathon_current_index]
	marathon_level_attempts[level_id] = marathon_level_attempts.get(level_id, 0) + 1

func complete_marathon_level() -> void:
	marathon_timer_running = false

	marathon_current_index += 1

	if marathon_current_index >= marathon_level_ids.size():
		level_title_label.text = ""
		BGMManager.fade_out(2.0)
		await transition_out()
		await unload_current_level()
		
		await get_tree().create_timer(1.5).timeout
		level_title_label.text = "[rainbow]DELIVERED![/rainbow]"
		pop_level_title_label()
		await get_tree().create_timer(2.5).timeout
		finish_marathon()
		return
	
	else:
		set_level_title_label_text(marathon_current_index)

	await transition_out()
	await unload_current_level()

	current_level_id = marathon_level_ids[marathon_current_index]

	# If your marathon uses worlds/current_level_index, advance that too.
	current_level_index += 1

	load_level()

	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	await transition_in()

	if level_controller_reference:
		level_controller_reference.enter_intro_state()

func register_marathon_death() -> void:
	if game_mode != GameMode.MARATHON:
		return

	marathon_timer_running = false
	marathon_deaths += 1

	var level_id := marathon_level_ids[marathon_current_index]
	marathon_level_attempts[level_id] = marathon_level_attempts.get(level_id, 0) + 1

func finish_marathon() -> void:
	marathon_timer_running = false
	marathon_finished = true
	
	var result = SaveManager.record_marathon_completion(
		current_marathon_data,
		marathon_time,
		marathon_deaths,
		marathon_level_attempts
	)
	
	show_marathon_results(result)

func show_marathon_results(result: Dictionary) -> void:
	var results_scene: PackedScene = null
	match result.marathon_id:
		"world_01", "world_02", "world_03":
			results_scene = MARATHON_RESULTS[result.marathon_id]
		_:
			results_scene = MARATHON_RESULTS["world_04"]
	
	var results_scene_instance = results_scene.instantiate()
	level_container.add_child(results_scene_instance)
	results_scene_instance.setup_marathon_results(result)
	await transition_in()
	results_scene_instance.show_results()

func retry_level() -> void:
	game_pausable = false

	var old_level: Node = null
	if level_container.get_child_count() > 0:
		old_level = level_container.get_child(0)

	var new_level := instantiate_current_level()
	if new_level == null:
		return

	# Keep the old level visible until the new one exists.
	level_container.move_child(new_level, 0)

	setup_loaded_level(new_level)

	if old_level:
		old_level.queue_free()

	await get_tree().process_frame

	if level_controller_reference:
		level_controller_reference.enter_intro_state()

	game_pausable = true


func load_next_level() -> void:
	if game_mode == GameMode.MARATHON:
		await complete_marathon_level()
		return

	var world_data := get_current_world_data()
	if world_data == null:
		return

	current_level_index += 1

	if current_level_index < world_data.levels.size():
		set_level_title_label_text(current_level_index)
	else:
		level_title_label.text = ""

	await transition_out()
	await unload_current_level()

	if current_level_index >= world_data.levels.size():
		var completed_world := world_data
		
		current_world_index += 1
		current_level_index = 0

		if current_world_index >= worlds.size():
			print("Game complete.")
			get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
			return

		var next_world := get_current_world_data()

		current_world_level_names.clear()
		current_world_level_names = get_world_level_names(current_world_index)

		await show_world_transition(completed_world, next_world)

	load_level()

	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	
	world_transition.visible = false
	
	await transition_in()

	if level_controller_reference:
		level_controller_reference.enter_intro_state()


func show_world_transition(completed_world: WorldData, next_world: WorldData) -> void:
	var world_data := get_current_world_data()
	if world_data == null:
		return
	
	await get_tree().create_timer(1.0).timeout
	
	await world_transition.play_transition(completed_world, next_world)
	
	set_level_title_label_text(current_level_index)
	
	await transition_out()

func _on_world_transition_transition_in() -> void:
	transition_in()


func unload_current_level() -> void:
	if level_container.get_child_count() == 0:
		return

	var current_level := level_container.get_child(0)
	current_level.queue_free()

	await get_tree().process_frame

	level_controller_reference = null


func enable_pause() -> void:
	game_pausable = true


func disable_pause() -> void:
	game_pausable = false


func get_current_world_data() -> WorldData:
	if current_world_index < 0 or current_world_index >= worlds.size():
		return null

	return worlds[current_world_index]


func get_current_level_data() -> LevelData:
	var world_data := get_current_world_data()
	if world_data == null:
		return null

	if current_level_index < 0 or current_level_index >= world_data.levels.size():
		return null

	return world_data.levels[current_level_index]

func setup_marathon_from_data(data: MarathonData) -> void:
	game_mode = GameMode.MARATHON
	current_marathon_data = data

	worlds = data.worlds
	LevelDatabase.setup(worlds)

	marathon_id = data.marathon_id
	marathon_level_ids = data.get_level_ids()
	marathon_current_index = 0

	marathon_time = 0.0
	marathon_timer_running = false
	marathon_deaths = 0
	marathon_level_attempts = {}

	for level_id in marathon_level_ids:
		marathon_level_attempts[level_id] = 0

	current_world_index = 0
	current_level_index = 0
	current_world_level_names = get_world_level_names(current_world_index)

	should_show_initial_world_transition = false


func _on_pause_screen_restart_marathon() -> void:
	if game_mode != GameMode.MARATHON or current_marathon_data == null:
		return

	get_tree().paused = false
	is_paused = false
	pause_screen.visible = false
	marathon_finished = false
	level_title_label.text = first_level_loaded_title
	
	await transition_out()
	await unload_current_level()

	setup_marathon_from_data(current_marathon_data)

	load_level()

	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	await transition_in()

	if level_controller_reference:
		level_controller_reference.enter_intro_state()

func pop_level_title_label() -> void:
	level_title_label.visible = true
	level_title_label.modulate.a = 0.0
	level_title_label.scale = Vector2(0.55, 0.55)
	level_title_label.pivot_offset = level_title_label.size / 2.0
	
	play_sfx(DELIVERED_SFX, DELIVERED_VOLUME, DELIVERED_PITCH_RANGE)
	
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(level_title_label, "modulate:a", 1.0, 0.10)

	tween.tween_property(level_title_label, "scale", Vector2(1.25, 1.25), 0.16)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_property(level_title_label, "scale", Vector2.ONE, 0.10)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

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
