extends CanvasLayer
class_name LevelUI

@export var level_controller_path: NodePath
@onready var level_controller: LevelController = get_node(level_controller_path)
@onready var complete_label: Label = $LevelUIControl/CompleteLabel
@onready var timer_label: Label = $LevelUIControl/TimerLabel

var complete_label_initial_position: Vector2

func _ready() -> void:
	complete_label.visible = false
	complete_label_initial_position = complete_label.position
	complete_label.position.y += 20

func _process(_delta: float) -> void:
	update_timer_display()

func show_complete_label() -> void:
	complete_label.visible = true
	
	var tween = create_tween()
	
	tween.tween_property(complete_label, "position:y", complete_label_initial_position.y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func update_timer_display() -> void:
	var time := level_controller.level_time
	timer_label.text = format_time(time)


func format_time(time: float) -> String:
	return "%.2f" % time
