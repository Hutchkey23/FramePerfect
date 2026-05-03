extends HBoxContainer
class_name InputPrompt

@export var action_name: String
@export var action_label: String

@onready var icon: TextureRect = $Icon
@onready var text: Label = $Text


func _ready() -> void:
	update_prompt()
	InputHelper.device_changed.connect(_on_device_changed)


func _on_device_changed(_device: String, _index: int) -> void:
	update_prompt()


func update_prompt() -> void:
	var input_event = InputHelper.get_keyboard_or_joypad_input_for_action(action_name)

	if input_event == null:
		icon.visible = false
		text.text = action_label
		return

	var icon_texture := get_icon_for_input(input_event)

	if icon_texture:
		icon.texture = icon_texture
		icon.visible = true
		text.text = action_label
	else:
		icon.visible = false
		var label_text = InputHelper.get_label_for_input(input_event)
		text.text = label_text + " " + action_label

func get_icon_for_input(input_event: InputEvent) -> Texture2D:
	if input_event is InputEventKey:
		return _get_keyboard_icon(input_event)

	elif input_event is InputEventJoypadButton:
		return _get_gamepad_icon(input_event)

	return null

func _get_keyboard_icon(event: InputEventKey) -> Texture2D:
	var key_string := InputHelper.get_label_for_input(event).to_lower()

	var path := "res://assets/ui/glyphs/keyboard/%s.png" % key_string

	if ResourceLoader.exists(path):
		return load(path)

	return null

func _get_gamepad_icon(event: InputEventJoypadButton) -> Texture2D:
	var device := _normalize_device_name(InputHelper.device)
	var label := InputHelper.get_label_for_input(event).to_lower()

	label = label.replace(" button", "")
	label = label.replace(" ", "_")

	var path := "res://assets/ui/glyphs/%s/%s.png" % [device, label]

	if ResourceLoader.exists(path):
		return load(path)

	var fallback_path := "res://assets/ui/glyphs/generic/%s.png" % label
	if ResourceLoader.exists(fallback_path):
		return load(fallback_path)

	print("Missing gamepad glyph: device=", device, " label=", label, " path=", path)
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

	return d
