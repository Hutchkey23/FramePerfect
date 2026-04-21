extends Node
class_name LevelController

signal load_next_level

enum LevelState {
	INTRO,
	PLAYING,
	COMPLETED,
	DEAD
}


@export var player_path: NodePath
@export var player_spawn_path: NodePath
@export var goal_path: NodePath
@export var camera_path: NodePath
@export var cinematic_bars_path: NodePath
@export var level_ui_path: NodePath

var current_state: LevelState = LevelState.INTRO
var level_time: float = 0.0
var timer_running: bool = false
var fixed_camera_level : bool = false


@onready var camera: GameCamera = get_node(camera_path)
@onready var cinematic_bars: CinematicBars = get_node(cinematic_bars_path)
@onready var level_ui: LevelUI = get_node(level_ui_path)
@onready var player: Player = get_node(player_path)
@onready var player_spawn: Node2D = get_node(player_spawn_path)
@onready var goal: Goal = get_node(goal_path)

func _ready() -> void:
	enter_intro_state()
	connect_signals()
	player.position = player_spawn.position
	
	if camera.mode == camera.CameraMode.FIXED:
		fixed_camera_level = true

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
	cinematic_bars.hide_bars()
	level_ui.hide_start_label()
	current_state = LevelState.PLAYING
	timer_running = true
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)


func complete_level() -> void:
	if current_state != LevelState.PLAYING:
		return
	
	current_state = LevelState.COMPLETED
	timer_running = false
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	
	level_ui.show_level_complete_prompts()
	
	cinematic_bars.show_bars()
	camera.zoom_to_target(goal, Vector2.ONE * 2.5, 0.2)
	goal.show_completion_label()


func fail_level() -> void:
	if current_state != LevelState.PLAYING:
		return
	
	current_state = LevelState.DEAD
	timer_running = false
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	
	level_ui.show_level_fail_prompts()
	cinematic_bars.show_bars()
	camera.zoom_to_target(player, Vector2.ONE * 2.5, 0.2)


func update_timer(delta: float) -> void:
	if timer_running:
		level_time += delta


func check_for_level_start_input() -> void:
	if Input.is_action_just_pressed("move_left") \
	or Input.is_action_just_pressed("move_right") \
	or Input.is_action_just_pressed("move_up") \
	or Input.is_action_just_pressed("move_down") \
	or Input.is_action_just_pressed("jump") \
	or Input.is_action_just_pressed("dash"):
		start_level()

func check_for_level_completed_input() -> void:
	if Input.is_action_just_pressed("continue_game"):
		load_next_level.emit()
	elif Input.is_action_just_pressed("retry"):
		retry_level()
	
func check_for_dead_input() -> void:
	if Input.is_action_just_pressed("retry"):
		retry_level()


func _on_player_died() -> void:
	fail_level()


func _on_goal_reached() -> void:
	complete_level()

func retry_level() -> void:
	player.retry_level()
	camera.retry_level()
	if not fixed_camera_level:
		camera.set_follow_target(player)
	goal.hide_completion_label()
	level_ui.retry_level()
	player.position = player_spawn.position
	enter_intro_state()
