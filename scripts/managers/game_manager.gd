extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_container: Node2D = $LevelContainer
@onready var transition: CanvasLayer = $Transition
@onready var level_title_label: RichTextLabel = $Transition/LevelTitleLabel
@onready var pause_screen: PauseMenu = $PauseLayer/PauseScreen
@onready var world_transition: WorldTransition = $WorldTransition

const TRANSITION_LENGTH: float = 1.25

@export var worlds: Array[WorldData]

var current_world_index: int = 0
var current_level_index: int = 0
var current_level_id: String
var current_world_level_names: Array = []
var level_controller_reference: LevelController

var should_show_initial_world_transition: bool = false

var game_pausable: bool = false
var is_paused: bool = false

func _ready() -> void:
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

	await start_run()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused or not game_pausable:
			return
		pause_game()


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
	level_title_label.text = level_title


func start_run() -> void:
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
