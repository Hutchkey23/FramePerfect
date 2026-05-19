extends Control
class_name InputRemapRow

signal remap_requested

@export var action_name: StringName
@export var action_label: String

@onready var action_name_button: CustomMenuButton = $HBoxContainer/ActionNameButton
@onready var keyboard_texture: TextureRect = $HBoxContainer/KeyboardTexture
@onready var gamepad_texture: TextureRect = $HBoxContainer/GamepadTexture

const EXCLUSIVE_GAMEPLAY_ACTIONS: Array[StringName] = [
	&"jump",
	&"dash",
]

func _ready() -> void:
	action_name_button.update_button_label_text(action_label)
	
	refresh_binding_display()
	
	InputHelper.device_changed.connect(_on_device_changed)

func refresh_binding_display() -> void:
	var keyboard_event := InputHelper.get_keyboard_input_for_action(action_name)
	var gamepad_event := InputHelper.get_joypad_input_for_action(action_name)

	keyboard_texture.texture = get_icon_for_input(keyboard_event)
	gamepad_texture.texture = get_icon_for_input(gamepad_event)

	keyboard_texture.visible = keyboard_texture.texture != null
	gamepad_texture.visible = gamepad_texture.texture != null

func apply_remap_event(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_apply_keyboard_remap(event)

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_apply_gamepad_remap(event)

	refresh_binding_display()


func _apply_keyboard_remap(new_event: InputEvent) -> void:
	var old_event := InputHelper.get_keyboard_input_for_action(action_name)
	var conflict_action := _find_keyboard_conflict(new_event)

	if conflict_action != StringName() and conflict_action != action_name:
		_clear_keyboard_inputs_for_action(conflict_action)

		if old_event != null:
			InputHelper.set_keyboard_input_for_action(conflict_action, old_event, false)

	_clear_keyboard_inputs_for_action(action_name)
	InputHelper.set_keyboard_input_for_action(action_name, new_event, false)


func _apply_gamepad_remap(new_event: InputEvent) -> void:
	var old_event := InputHelper.get_joypad_input_for_action(action_name)
	var conflict_action := _find_gamepad_conflict(new_event)

	if conflict_action != StringName() and conflict_action != action_name:
		_clear_gamepad_inputs_for_action(conflict_action)

		if old_event != null:
			InputHelper.set_joypad_input_for_action(conflict_action, old_event, false)

	_clear_gamepad_inputs_for_action(action_name)
	InputHelper.set_joypad_input_for_action(action_name, new_event, false)


func _find_keyboard_conflict(target_event: InputEvent) -> StringName:
	for action in EXCLUSIVE_GAMEPLAY_ACTIONS:
		var existing_event := InputHelper.get_keyboard_input_for_action(action)

		if existing_event != null and existing_event.is_match(target_event):
			return action

	return StringName()


func _find_gamepad_conflict(target_event: InputEvent) -> StringName:
	for action in EXCLUSIVE_GAMEPLAY_ACTIONS:
		var existing_event := InputHelper.get_joypad_input_for_action(action)

		if existing_event != null and existing_event.is_match(target_event):
			return action

	return StringName()


func _clear_keyboard_inputs_for_action(target_action: StringName) -> void:
	for existing_event in InputMap.action_get_events(target_action):
		if existing_event is InputEventKey or existing_event is InputEventMouseButton:
			InputMap.action_erase_event(target_action, existing_event)


func _clear_gamepad_inputs_for_action(target_action: StringName) -> void:
	for existing_event in InputMap.action_get_events(target_action):
		if existing_event is InputEventJoypadButton or existing_event is InputEventJoypadMotion:
			InputMap.action_erase_event(target_action, existing_event)

func _on_device_changed(_device: String, _index: int) -> void:
	refresh_binding_display()


func get_icon_for_input(input_event: InputEvent) -> Texture2D:
	if input_event == null:
		return null

	if input_event is InputEventKey or input_event is InputEventMouseButton:
		return _get_keyboard_icon(input_event)

	elif input_event is InputEventJoypadButton or input_event is InputEventJoypadMotion:
		return _get_gamepad_icon(input_event)

	return null


func _get_keyboard_icon(event: InputEvent) -> Texture2D:
	var key_string := InputHelper.get_label_for_input(event).to_lower()

	key_string = key_string.replace(" ", "_")

	var path := "res://assets/ui/glyphs/keyboard/%s.png" % key_string

	if ResourceLoader.exists(path):
		return load(path)

	print("Missing keyboard/mouse glyph: ", key_string)
	return null

func _get_gamepad_icon(event: InputEvent) -> Texture2D:
	var device := _normalize_device_name(InputHelper.device)
	var label := InputHelper.get_label_for_input(event).to_lower()
	
	label = label.replace(" button", "")
	label = label.replace(" ", "_")

	var path := "res://assets/ui/glyphs/%s/%s.png" % [device, label]

	if ResourceLoader.exists(path):
		return load(path)

	var fallback_path := "res://assets/ui/glyphs/playstation/%s.png" % label

	if ResourceLoader.exists(fallback_path):
		return load(fallback_path)

	print("Missing gamepad glyph: device=", device, " label=", label)

	return null

func _normalize_device_name(device: String) -> String:
	var d := device.to_lower()

	match d:
		"steam deck", "steam_deck", "steamdeck":
			return "steam_deck"

		"xbox", "xbox_controller", "xinput":
			return "xbox"

		"playstation", "ps", "ps4", "ps5", "dualshock", "dualsense":
			return "playstation"

		"switch", "nintendo":
			return "switch"

	return "generic"


func set_remap_enabled(enabled: bool) -> void:
	action_name_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	action_name_button.disabled = not enabled

	if not enabled:
		action_name_button.release_focus()


func grab_silent_focus() -> void:
	action_name_button.grab_silent_focus()

func _on_action_name_button_pressed() -> void:
	remap_requested.emit(self)
