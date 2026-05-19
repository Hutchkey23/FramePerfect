extends Button
class_name InputRemapButton

@onready var button_texture: TextureRect = $HBoxContainer/ButtonTexture
@onready var indicator: TextureRect = $HBoxContainer/IndicatorControl/Indicator

enum RemapDevice {
	KEYBOARD,
	GAMEPAD
}

@export var action_name: StringName
@export var remap_device: RemapDevice = RemapDevice.KEYBOARD
@export var waiting_text: String = "..."

const FOCUSED_SIZE: Vector2 = Vector2(1.4, 1.4)
const ROTATION_OPTIONS: Array[float] = [-2.0, 2.0]
const INDICATOR_ROTATION_SPEED : float = 350.0
const BUTTON_FOCUSED_COLOR : Color = "#ffec27"
const PRESSED_SCALE : Vector2 = Vector2(0.9, 0.9)

var ignore_focus_sfx: bool = false

var button_tween: Tween
var press_tween: Tween


func _ready() -> void:
	call_deferred("update_pivot")

func _process(delta: float) -> void:
	indicator.rotation_degrees += INDICATOR_ROTATION_SPEED * delta

func update_pivot() -> void:
	pivot_offset = size / 2.0
	indicator.pivot_offset = indicator.size / 2.0

func grab_silent_focus() -> void:
	ignore_focus_sfx = true
	await get_tree().process_frame
	grab_focus()

func _on_resized() -> void:
	pivot_offset = size / 2.0

func _on_focus_entered() -> void:
	if button_tween:
		button_tween.kill()
	
	if not ignore_focus_sfx:
		UIAudioManager.play_ui_nav_sfx()
	
	button_tween = create_tween()
	button_tween.set_parallel(true)
	button_tween.tween_property(self, "scale", FOCUSED_SIZE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(self, "rotation_degrees", ROTATION_OPTIONS.pick_random(), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	button_texture.modulate = BUTTON_FOCUSED_COLOR
	
	indicator.texture = SkinDatabase.retrieve_skin_texture("player", SaveManager.save_data.cosmetics.selected_player_skin)
	
	indicator.modulate.a = 1.0
	
	ignore_focus_sfx = false

func _on_focus_exited() -> void:
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	button_tween.set_parallel(true)
	button_tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(self, "rotation_degrees", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	button_texture.modulate = Color.WHITE
	
	indicator.modulate.a = 0.0


func _on_pressed() -> void:
	if press_tween:
		press_tween.kill()
	
	UIAudioManager.play_ui_confirm_sfx()
	
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
