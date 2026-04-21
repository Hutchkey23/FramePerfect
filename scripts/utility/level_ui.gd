extends CanvasLayer
class_name LevelUI

@export var level_controller_path: NodePath
@onready var level_controller: LevelController = get_node(level_controller_path)

@onready var level_start_label: Label = $LevelUIControl/LevelStartLabel
@onready var level_complete_prompts: HBoxContainer = $LevelUIControl/LevelCompletePrompts
@onready var level_fail_prompts: HBoxContainer = $LevelUIControl/LevelFailPrompts
@onready var timer_label: Label = $LevelUIControl/TimerLabel


var level_complete_prompts_initial_position: Vector2
var level_fail_prompts_initial_position: Vector2

const OFFSCREEN_Y_OFFSET : float = 20.0

var level_complete_tween : Tween
var level_fail_tween : Tween

func _ready() -> void:
	level_complete_prompts.visible = false
	level_complete_prompts_initial_position = level_complete_prompts.position
	level_complete_prompts.position.y = level_complete_prompts_initial_position.y + OFFSCREEN_Y_OFFSET
	
	level_fail_prompts.visible = false
	level_fail_prompts_initial_position = level_fail_prompts.position
	level_fail_prompts.position.y = level_fail_prompts_initial_position.y + OFFSCREEN_Y_OFFSET

func _process(_delta: float) -> void:
	update_timer_display()

func show_level_complete_prompts() -> void:
	if level_complete_tween:
		level_complete_tween.kill()
	
	level_complete_prompts.visible = true
	
	level_complete_tween = create_tween()
	
	level_complete_tween.tween_property(level_complete_prompts, "position:y", level_complete_prompts_initial_position.y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func show_level_fail_prompts() -> void:
	if level_fail_tween:
		level_fail_tween.kill()
	
	level_fail_prompts.visible = true
	
	level_fail_tween = create_tween()
	
	level_fail_tween.tween_property(level_fail_prompts, "position:y", level_fail_prompts_initial_position.y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func update_timer_display() -> void:
	var time := level_controller.level_time
	timer_label.text = format_time(time)


func format_time(time: float) -> String:
	return "%.2f" % time


func retry_level():
	if level_fail_tween:
		level_fail_tween.kill()
	
	if level_complete_tween:
		level_complete_tween.kill()
	
	level_complete_prompts.visible = false
	level_complete_prompts.position.y = level_complete_prompts_initial_position.y + OFFSCREEN_Y_OFFSET
	
	level_fail_prompts.visible = false
	level_fail_prompts.position.y = level_fail_prompts_initial_position.y + OFFSCREEN_Y_OFFSET
	
	show_start_label()

func hide_start_label() -> void:
	level_start_label.visible = false
	
func show_start_label() -> void:
	level_start_label.visible = true
