extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var logo_container: MarginContainer = $MainTitleVbox/LogoContainer
@onready var play_button: CustomMenuButton = $MainTitleVbox/PlayButton
@onready var marathon_button: CustomMenuButton = $MainTitleVbox/MarathonButton
@onready var level_select_button: CustomMenuButton = $MainTitleVbox/LevelSelectButton
@onready var customize_button: CustomMenuButton = $MainTitleVbox/CustomizeButton
@onready var options_button: CustomMenuButton = $MainTitleVbox/OptionsButton
@onready var quit_button: CustomMenuButton = $MainTitleVbox/QuitButton

@onready var main_menu_buttons := [
	play_button,
	marathon_button,
	level_select_button,
	customize_button,
	options_button,
	quit_button
]

const ROTATION_AMOUNT: float = 2.0
const ROTATION_SPEED: float = 2.0

var time: float = 0.0

func _ready() -> void:
	call_deferred("setup_pivots")
	
	animation_player.play("transition_in")
	
	play_button.grab_focus()


func setup_pivots() -> void:
	logo_container.pivot_offset = logo_container.size / 2.0


func _process(delta: float) -> void:
	time += delta
	logo_container.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT

func _on_logo_container_resized() -> void:
	if not logo_container:
		return
	logo_container.pivot_offset = logo_container.size / 2.0


func _on_play_button_pressed() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/managers/game_manager.tscn")


func _on_marathon_button_pressed() -> void:
	pass # Replace with function body.


func _on_level_select_button_pressed() -> void:
	pass # Replace with function body.


func _on_customize_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
