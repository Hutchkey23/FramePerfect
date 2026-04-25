extends Control
class_name PauseMenu

signal resume_game
signal retry_level
signal go_to_main_menu

@onready var paused_label: Label = $VBoxContainer/PausedLabel

@onready var resume_button: CustomMenuButton = $VBoxContainer/HBoxContainer/ResumeButton
@onready var retry_button: CustomMenuButton = $VBoxContainer/HBoxContainer/RetryButton
@onready var main_menu_button: CustomMenuButton = $VBoxContainer/HBoxContainer/MainMenuButton

const ROTATION_SPEED : float = 1.0
const ROTATION_AMOUNT : float = 10.0

var time : float = 0.0

func _ready() -> void:
	call_deferred("prepare_pause_menu")

func update_pivot() -> void:
	if paused_label:
		paused_label.pivot_offset = paused_label.size / 2

func _process(delta: float) -> void:
	time += delta
	
	paused_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	resume_game.emit()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	retry_level.emit()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	go_to_main_menu.emit()


func _on_visibility_changed() -> void:
	if visible:
		call_deferred("prepare_pause_menu")

func prepare_pause_menu() -> void:
	await get_tree().process_frame
	
	update_pivot()
	resume_button.grab_focus()


func _on_paused_label_resized() -> void:
	update_pivot()
