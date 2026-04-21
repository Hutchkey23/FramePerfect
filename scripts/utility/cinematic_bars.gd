extends CanvasLayer
class_name CinematicBars

@onready var cinematic_bars_control: Control = $CinematicBarsControl
@export var bar_height: float = 25.0
@export var tween_time: float = 0.35

@onready var top_bar: ColorRect = $CinematicBarsControl/TopBar
@onready var bottom_bar: ColorRect = $CinematicBarsControl/BottomBar

var bars_tween: Tween

func _ready() -> void:
	top_bar.custom_minimum_size.y = 0.0
	bottom_bar.custom_minimum_size.y = 0.0
	bottom_bar.pivot_offset.y = bottom_bar.size.y
	_update_bar_layout(20.0)


func show_bars() -> void:
	_tween_bars(bar_height)


func hide_bars() -> void:
	_tween_bars(0.0)


func _tween_bars(target_height: float) -> void:
	if bars_tween:
		bars_tween.kill()

	bars_tween = create_tween()
	bars_tween.set_parallel(true)

	bars_tween.tween_method(_update_top_bar, top_bar.size.y, target_height, tween_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	bars_tween.tween_method(_update_bottom_bar, bottom_bar.size.y, target_height, tween_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


func _update_top_bar(height: float) -> void:
	height = round(height)
	top_bar.size.y = height
	top_bar.position.y = 0.0


func _update_bottom_bar(height: float) -> void:
	height = round(height)
	bottom_bar.size.y = height
	bottom_bar.position.y = cinematic_bars_control.size.y - height


func _update_bar_layout(height: float) -> void:
	_update_top_bar(height)
	_update_bottom_bar(height)
