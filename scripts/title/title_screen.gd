extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var logo_container: MarginContainer = $MainTitleVbox/LogoContainer
@onready var play_button: CustomMenuButton = $MainTitleVbox/PlayButton
@onready var marathon_button: CustomMenuButton = $MainTitleVbox/MarathonButton
@onready var level_select_button: CustomMenuButton = $MainTitleVbox/LevelSelectButton
@onready var customize_button: CustomMenuButton = $MainTitleVbox/CustomizeButton
@onready var options_button: CustomMenuButton = $MainTitleVbox/OptionsButton
@onready var quit_button: CustomMenuButton = $MainTitleVbox/QuitButton
@onready var wishlist_button: CustomMenuButton = $MainTitleVbox/WishlistButton

@onready var main_title_vbox: VBoxContainer = $MainTitleVbox
@onready var customize_menu: CustomizeMenu = $CustomizeMenu
@onready var level_select: Control = $LevelSelect
@onready var marathon_level_select: MarathonLevelSelect = $MarathonLevelSelect
@onready var options_menu: OptionsMenu = $OptionsMenu

@onready var main_menu_buttons: Array[CustomMenuButton] = [
	play_button,
	marathon_button,
	level_select_button,
	customize_button,
	options_button,
	quit_button
]

const ROTATION_AMOUNT: float = 2.0
const ROTATION_SPEED: float = 2.0

var changing_scenes: bool = false

var time: float = 0.0

func _ready() -> void:
	call_deferred("setup_pivots")
	
	options_menu.data_cleared.connect(setup_unlock_states)
	
	if BuildConfig.IS_DEMO:
		customize_button.visible = false
		main_menu_buttons.append(wishlist_button)
		wishlist_button.visible = true
	
	setup_unlock_states()
	
	animation_player.play("transition_in")
	
	play_button.grab_silent_focus()
	
	BGMManager.play(BGMManager.SEND_IT)

func setup_unlock_states() -> void:
	var marathon_id := BuildConfig.get_main_marathon_id()

	if SaveManager.is_marathon_unlocked(marathon_id):
		marathon_button.enable_button()
	else:
		marathon_button.disable_button()

func setup_pivots() -> void:
	logo_container.pivot_offset = logo_container.size / 2.0


func _process(delta: float) -> void:
	time += delta
	logo_container.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT

func disable_menu_buttons() -> void:
	for menu_button in main_menu_buttons:
		menu_button.focus_mode = Control.FOCUS_NONE

func _on_logo_container_resized() -> void:
	if not logo_container:
		return
	logo_container.pivot_offset = logo_container.size / 2.0


func _on_play_button_pressed() -> void:
	if changing_scenes:
		return
	
	changing_scenes = true
	
	disable_menu_buttons()
	
	BGMManager.fade_out(1.5)
	
	animation_player.play("global_transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/managers/game_manager.tscn")


func _on_marathon_button_pressed() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	main_title_vbox.visible = false
	marathon_level_select.visible = true
	animation_player.play("transition_in")


func _on_level_select_button_pressed() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	main_title_vbox.visible = false
	level_select.visible = true
	animation_player.play("transition_in")


func _on_customize_button_pressed() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	main_title_vbox.visible = false
	customize_menu.visible = true
	animation_player.play("transition_in")

func _on_customize_menu_exit_customize_menu() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	customize_menu.visible = false
	main_title_vbox.visible = true
	customize_button.grab_silent_focus()
	animation_player.play("transition_in")

func _on_level_select_exit_level_select() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	level_select.visible = false
	main_title_vbox.visible = true
	level_select_button.grab_silent_focus()
	animation_player.play("transition_in")

func _on_marathon_level_select_exit_level_select() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	marathon_level_select.visible = false
	main_title_vbox.visible = true
	marathon_button.grab_silent_focus()
	animation_player.play("transition_in")

func _on_options_button_pressed() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	main_title_vbox.visible = false
	options_menu.visible = true
	animation_player.play("transition_in")

func _on_options_menu_exit_options_menu() -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished
	options_menu.visible = false
	main_title_vbox.visible = true
	options_button.grab_silent_focus()
	animation_player.play("transition_in")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_level_select_level_selected(world_data: WorldData, level_data: LevelData) -> void:
	RunState.select_level(world_data, level_data)
	_on_play_button_pressed()


func _on_marathon_level_select_marathon_selected(data: MarathonData) -> void:
	RunState.set_pending_marathon(data)
	_on_play_button_pressed()


func _on_wishlist_button_pressed() -> void:
	OS.shell_open("https://store.steampowered.com/app/4743330/Send_It/")
