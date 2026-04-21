extends CanvasLayer
class_name LevelUI

@export var level_controller_path: NodePath
@onready var level_controller: LevelController = get_node(level_controller_path)
@onready var level_complete_prompts: HBoxContainer = $LevelUIControl/LevelCompletePrompts
@onready var timer_label: Label = $LevelUIControl/TimerLabel

var level_complete_prompts_initial_position: Vector2

func _ready() -> void:
	level_complete_prompts.visible = false
	level_complete_prompts_initial_position = level_complete_prompts.position
	level_complete_prompts.position.y += 20

func _process(_delta: float) -> void:
	update_timer_display()

func show_level_complete_prompts() -> void:
	level_complete_prompts.visible = true
	
	var tween = create_tween()
	
	tween.tween_property(level_complete_prompts, "position:y", level_complete_prompts_initial_position.y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func update_timer_display() -> void:
	var time := level_controller.level_time
	timer_label.text = format_time(time)


func format_time(time: float) -> String:
	return "%.2f" % time
