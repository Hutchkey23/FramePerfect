extends Node
class_name LevelController

signal level_completed
signal level_failed
signal level_started
signal load_next_level
signal retry_level_requested

enum LevelState {
	LOADING,
	INTRO,
	PLAYING,
	COMPLETED,
	DEAD
}

const STAMP = preload("uid://dpvbyd8v5auob")

@export var player_path: NodePath
@export var player_spawn_path: NodePath
@export var goal_path: NodePath
@export var camera_path: NodePath
@export var cinematic_bars_path: NodePath
@export var level_ui_path: NodePath
@export var platforms_path: NodePath
@export var hazards_path: NodePath
@export var toggle_blocks_path: NodePath

var game_manager: GameManager = null

var level_id : String = ""

var current_state: LevelState = LevelState.LOADING
var level_time: float = 0.0
var timer_running: bool = false
var fixed_camera_level : bool = false
var loading_next_level : bool = false

@onready var camera: GameCamera = get_node(camera_path)
@onready var cinematic_bars: CinematicBars = get_node(cinematic_bars_path)
@onready var level_ui: LevelUI = get_node(level_ui_path)
@onready var player: Player = get_node(player_path)
@onready var player_spawn: Node2D = get_node(player_spawn_path)
@onready var goal: Goal = get_node(goal_path)

@onready var stamps: Node2D = get_node_or_null("../Stamps")
@onready var platforms_container: Node2D = get_node_or_null(platforms_path)
@onready var hazards_container: Node2D = get_node_or_null(hazards_path)
@onready var toggle_blocks_container: Node2D = get_node_or_null(toggle_blocks_path)

# ANALOG #
const ANALOG_START_THRESHOLD: float = 0.55
var analog_start_was_pressed: bool = false

func _ready() -> void:
	 ##DEBUG
	#enter_intro_state()
	 ##END DEBUG
	
	connect_signals()
	player.position = player_spawn.position
	player.set_control_enabled(false)
	if camera.mode == camera.CameraMode.FIXED:
		fixed_camera_level = true
	
	game_manager = get_tree().get_first_node_in_group("game_manager")
	
	spawn_stamps()

func _process(delta: float) -> void:
	match current_state:
		LevelState.INTRO:
			check_for_level_start_input()
		LevelState.PLAYING:
			update_timer(delta)
		LevelState.DEAD:
			check_for_dead_input()
		LevelState.COMPLETED:
			check_for_level_completed_input()

func setup_level(new_level_id: String) -> void:
	level_id = new_level_id
	
	if goal:
		goal.setup_level(level_id)

func connect_signals() -> void:
	if player.has_signal("died"):
		player.died.connect(_on_player_died)

	if player.has_signal("goal_reached"):
		player.goal_reached.connect(_on_goal_reached)


func enter_intro_state() -> void:
	current_state = LevelState.INTRO
	timer_running = false
	level_time = 0.0
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)

func start_level() -> void:
	level_started.emit()
	
	cinematic_bars.hide_bars()
	level_ui.hide_start_label()
	current_state = LevelState.PLAYING
	timer_running = true
	
	if game_manager and game_manager.game_mode == game_manager.GameMode.MARATHON:
		game_manager.register_marathon_attempt_started()
		game_manager.start_marathon_timer()
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)


func complete_level() -> void:
	if current_state != LevelState.PLAYING:
		return
	
	level_completed.emit()
	
	current_state = LevelState.COMPLETED
	timer_running = false
	
	if game_manager and game_manager.game_mode == game_manager.GameMode.MARATHON:
		game_manager.pause_marathon_timer()
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	
	if game_manager and game_manager.game_mode == game_manager.GameMode.MARATHON:
		level_ui.show_marathon_level_complete_prompts()
	else:
		level_ui.show_level_complete_prompts()
	
	var result : Dictionary = SaveManager.record_level_completion(level_id, level_time)
	goal.show_level_complete_result(result)
	
	cinematic_bars.show_bars()
	camera.zoom_to_target(goal, Vector2.ONE * 2.5, 0.2)


func fail_level() -> void:
	if current_state != LevelState.PLAYING:
		return
	
	level_failed.emit()
	
	current_state = LevelState.DEAD
	timer_running = false
	
	if game_manager:
		game_manager.register_marathon_death()
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	
	level_ui.show_level_fail_prompts()
	cinematic_bars.show_bars()
	camera.zoom_to_target(player, Vector2.ONE * 2.5, 0.2)

func update_timer(delta: float) -> void:
	if timer_running:
		level_time += delta


func check_for_level_start_input() -> void:
	var analog_start_pressed := is_analog_start_just_pressed()
	
	if Input.is_action_just_pressed("move_left") \
	or Input.is_action_just_pressed("move_right") \
	or Input.is_action_just_pressed("move_up") \
	or Input.is_action_just_pressed("move_down") \
	or Input.is_action_just_pressed("jump") \
	or Input.is_action_just_pressed("dash") \
	or analog_start_pressed:
		start_level()


func is_analog_start_just_pressed() -> bool:
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	var is_pressed := stick.length() >= ANALOG_START_THRESHOLD
	var just_pressed := is_pressed and not analog_start_was_pressed
	
	analog_start_was_pressed = is_pressed
	
	return just_pressed

func check_for_level_completed_input() -> void:
	if Input.is_action_just_pressed("continue_game"):
		if loading_next_level:
			return
		loading_next_level = true
		load_next_level.emit()
	elif Input.is_action_just_pressed("retry") and game_manager.game_mode != game_manager.GameMode.MARATHON:
		retry_level()
	
func check_for_dead_input() -> void:
	if Input.is_action_just_pressed("retry"):
		retry_level()


func _on_player_died() -> void:
	fail_level()


func _on_goal_reached() -> void:
	complete_level()

func retry_level() -> void:
	retry_level_requested.emit()
	return
	despawn_stamps()
	await get_tree().process_frame
	spawn_stamps()
	
	reset_toggle_blocks()
	
	cinematic_bars.show_bars()
	
	player.retry_level()
	camera.retry_level()
	if not fixed_camera_level:
		camera.set_follow_target(player)
	goal.retry_level()
	level_ui.retry_level()
	player.position = player_spawn.position
	enter_intro_state()

func reset_toggle_blocks() -> void:
	if not toggle_blocks_container:
		return
	
	for toggle_block in toggle_blocks_container.get_children():
		toggle_block._ready()

func spawn_stamps() -> void:
	var stamps_in_level: bool = false
	for stamp_location in stamps.get_children():
		var new_stamp = STAMP.instantiate()
		add_child(new_stamp)
		new_stamp.global_position = stamp_location.global_position
		stamps_in_level = true
	
	if stamps_in_level:
		goal.stamps_remaining = stamps.get_child_count()
		goal.check_if_goal_available()
		goal.setup_stamps()

func despawn_stamps() -> void:
	for stamp in get_tree().get_nodes_in_group("stamps"):
		stamp.queue_free()

func get_all_children(node: Node) -> Array:
	var result := []
	for child in node.get_children():
		result.append(child)
		result += get_all_children(child)
	return result
