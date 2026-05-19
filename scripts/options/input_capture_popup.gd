extends Control
class_name InputCapturePopup

signal input_captured(event: InputEvent)
signal capture_cancelled

@onready var action_label: Label = $PanelContainer/VBoxContainer/ActionLabel

var is_capturing: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(false)


func open(action_label_text: String) -> void:
	visible = true
	is_capturing = true
	set_process_unhandled_input(true)
	
	action_label.text = action_label_text
	
	grab_focus()

func close() -> void:
	visible = false
	is_capturing = false
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if not is_capturing:
		return

	# Keyboard
	if event is InputEventKey:
		if not event.is_pressed() or event.is_echo():
			return

		get_viewport().set_input_as_handled()

		if event.keycode == KEY_ESCAPE:
			cancel_capture()
			return

		input_captured.emit(event)
		close()
		return

	# Gamepad buttons
	if event is InputEventJoypadButton:
		if not event.is_pressed():
			return

		# Ignore dpad
		if is_dpad_button(event.button_index):
			return

		get_viewport().set_input_as_handled()

		input_captured.emit(event)
		close()
		return
	
	# Gamepad triggers / analog axes
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) < 0.7:
			return

		# Only allow L2/R2 triggers, not sticks
		if event.axis != JOY_AXIS_TRIGGER_LEFT and event.axis != JOY_AXIS_TRIGGER_RIGHT:
			return

		get_viewport().set_input_as_handled()

		input_captured.emit(event)
		close()
		return

func is_dpad_button(button_index: int) -> bool:
	return button_index in [
		JOY_BUTTON_DPAD_UP,
		JOY_BUTTON_DPAD_DOWN,
		JOY_BUTTON_DPAD_LEFT,
		JOY_BUTTON_DPAD_RIGHT,
	]

func cancel_capture() -> void:
	capture_cancelled.emit()
	close()
