extends Node
class_name LevelController

enum LevelState {
	INTRO,
	PLAYING,
	COMPLETED,
	DEAD
}

@export var player_path: NodePath
@export var goal_path: NodePath

var current_state: LevelState = LevelState.INTRO
var level_time: float = 0.0
var timer_running: bool = false

@onready var player: Player = get_node(player_path)
@onready var goal = get_node(goal_path)

func _ready() -> void:
	enter_intro_state()
	connect_signals()


func _process(delta: float) -> void:
	match current_state:
		LevelState.INTRO:
			check_for_level_start_input()
		LevelState.PLAYING:
			update_timer(delta)


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
	
	print("LEVEL COMPLETE")
	print("Time: ", snapped(level_time, 0.001))


func fail_level() -> void:
	if current_state != LevelState.PLAYING:
		return
	
	current_state = LevelState.DEAD
	timer_running = false
	
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	
	print("PLAYER DIED")
	get_tree().reload_current_scene()


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


func _on_player_died() -> void:
	fail_level()


func _on_goal_reached() -> void:
	complete_level()
