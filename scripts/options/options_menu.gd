extends Control
class_name OptionsMenu

signal exit_options_menu
signal data_cleared

@onready var return_button: CustomMenuButton = $PanelContainer/OptionsVbox/ReturnButton
@onready var controls_button: CustomMenuButton = $PanelContainer/OptionsVbox/ControlsButton
@onready var sfx_slider: VolumePipSlider = $PanelContainer/OptionsVbox/SFXSlider
@onready var music_slider: VolumePipSlider = $PanelContainer/OptionsVbox/MusicSlider
@onready var display_mode_button: CustomMenuButton = $PanelContainer/OptionsVbox/DisplayModeButton
@onready var screen_shake_button: CustomMenuButton = $PanelContainer/OptionsVbox/ScreenShakeButton
@onready var clear_data_button: CustomMenuButton = $PanelContainer/OptionsVbox/ClearDataButton
@onready var clear_data_confirm_popup: Control = $ClearDataConfirmPopup
@onready var controls_menu: ControlsMenu = $ControlsMenu

var interactables: Array = []
var screen_shake_enabled: bool = true


func _ready() -> void:
	return_button.grab_silent_focus()

	controls_menu.close_controls_menu.connect(_on_close_controls_menu)

	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	clear_data_button.pressed.connect(_on_clear_data_pressed)

	interactables = [
		return_button,
		controls_button,
		sfx_slider,
		music_slider,
		display_mode_button,
		screen_shake_button,
		clear_data_button
	]

	load_options()
	call_deferred("update_pivot")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		exit_options_menu.emit()
		UIAudioManager.play_ui_cancel_sfx()
		get_viewport().set_input_as_handled()


func update_pivot() -> void:
	await get_tree().process_frame

	for interactable in interactables:
		interactable.pivot_offset = interactable.size / 2.0


func load_options() -> void:
	sfx_slider.value = SaveManager.get_option("sfx_volume", 3)
	music_slider.value = SaveManager.get_option("music_volume", 3)
	screen_shake_enabled = SaveManager.get_option("screen_shake", true)

	SettingsManager.apply_all_settings()

	sfx_slider.update_display()
	music_slider.update_display()

	update_display_mode_text()
	update_screen_shake_text()


func _on_return_pressed() -> void:
	exit_options_menu.emit()


func _on_controls_button_pressed() -> void:
	disable_interactables()
	controls_menu.visible = true


func _on_close_controls_menu() -> void:
	controls_menu.visible = false
	enable_interactables()
	controls_button.grab_silent_focus()


func _on_sfx_volume_changed(value: int) -> void:
	SaveManager.set_option("sfx_volume", value)
	SettingsManager.apply_audio_settings()


func _on_music_volume_changed(value: int) -> void:
	SaveManager.set_option("music_volume", value)
	SettingsManager.apply_audio_settings()


func _on_display_mode_pressed() -> void:
	var current_mode := DisplayServer.window_get_mode()
	var fullscreen := current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN

	SaveManager.set_option("fullscreen", fullscreen)
	SettingsManager.apply_display_settings()

	update_display_mode_text()


func update_display_mode_text() -> void:
	var current_mode := DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		display_mode_button.update_button_label_text("DISPLAY: FULLSCREEN")
	else:
		display_mode_button.update_button_label_text("DISPLAY: WINDOWED")


func _on_screen_shake_pressed() -> void:
	screen_shake_enabled = not screen_shake_enabled
	SaveManager.set_option("screen_shake", screen_shake_enabled)

	update_screen_shake_text()


func update_screen_shake_text() -> void:
	if screen_shake_enabled:
		screen_shake_button.update_button_label_text("SCREEN SHAKE: ON")
	else:
		screen_shake_button.update_button_label_text("SCREEN SHAKE: OFF")


func _on_clear_data_pressed() -> void:
	disable_interactables()
	clear_data_confirm_popup.visible = true
	clear_data_confirm_popup.cancel_button.grab_silent_focus()


func disable_interactables() -> void:
	for interactable in interactables:
		interactable.focus_mode = Control.FOCUS_NONE


func enable_interactables() -> void:
	for interactable in interactables:
		interactable.focus_mode = Control.FOCUS_ALL


func _on_clear_data_confirm_popup_cancel_button_pressed() -> void:
	enable_interactables()
	clear_data_confirm_popup.visible = false
	clear_data_button.grab_silent_focus()


func _on_clear_data_confirm_popup_confirm_button_pressed() -> void:
	enable_interactables()

	SaveManager.clear_save_data()
	load_options()

	clear_data_confirm_popup.visible = false
	clear_data_button.grab_silent_focus()
	data_cleared.emit()


func _on_visibility_changed() -> void:
	if visible:
		enable_interactables()
		await update_pivot()
		return_button.grab_silent_focus()
	else:
		disable_interactables()
