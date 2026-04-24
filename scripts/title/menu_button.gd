extends Button
class_name CustomMenuButton

@onready var button_text: Label = $HBoxContainer/ButtonText
@onready var indicator: TextureRect = $HBoxContainer/IndicatorControl/Indicator


@export var button_label_text : String = ""

const FOCUSED_SIZE: Vector2 = Vector2(1.4, 1.4)
const ROTATION_OPTIONS: Array[float] = [-2.0, 2.0]
const INDICATOR_ROTATION_SPEED : float = 350.0
const LABEL_FOCUSED_COLOR : Color = "#ffec27"
const PRESSED_SCALE : Vector2 = Vector2(0.9, 0.9)

var button_tween: Tween
var press_tween: Tween


func _ready() -> void:
	call_deferred("update_pivot")
	button_text.text = button_label_text

func _process(delta: float) -> void:
	indicator.rotation_degrees += INDICATOR_ROTATION_SPEED * delta

func update_pivot() -> void:
	pivot_offset = size / 2.0
	indicator.pivot_offset = indicator.size / 2.0

func _on_resized() -> void:
	pivot_offset = size / 2.0

func _on_focus_entered() -> void:
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	button_tween.set_parallel(true)
	button_tween.tween_property(self, "scale", FOCUSED_SIZE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(self, "rotation_degrees", ROTATION_OPTIONS.pick_random(), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	button_text.add_theme_color_override("font_color", LABEL_FOCUSED_COLOR)
	
	indicator.modulate.a = 1.0

func _on_focus_exited() -> void:
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	button_tween.set_parallel(true)
	button_tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(self, "rotation_degrees", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	button_text.add_theme_color_override("font_color", Color.WHITE)
	
	indicator.modulate.a = 0.0


func _on_pressed() -> void:
	if press_tween:
		press_tween.kill()
	
	press_tween = create_tween()
	press_tween.set_parallel(true)
	# Squash down quickly
	press_tween.tween_property(self, "scale", PRESSED_SCALE, 0.05)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	press_tween.tween_property(self, "rotation_degrees", rotation_degrees + 3.0, 0.05)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	# Snap back
	press_tween.chain()
	press_tween.tween_property(self, "scale", FOCUSED_SIZE, 0.08)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	press_tween.tween_property(self, "rotation_degrees", 0.0, 0.08)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
