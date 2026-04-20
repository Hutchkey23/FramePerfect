extends CanvasLayer

@export var level_controller_path: NodePath
@onready var level_controller: LevelController = get_node(level_controller_path)

@onready var timer_label: Label = $LevelUIControl/TimerLabel

func _process(_delta: float) -> void:
	update_timer_display()


func update_timer_display() -> void:
	var time := level_controller.level_time
	timer_label.text = format_time(time)


func format_time(time: float) -> String:
	return "%.2f" % time
