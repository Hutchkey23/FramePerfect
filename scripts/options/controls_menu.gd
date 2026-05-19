extends Control
class_name ControlsMenu

signal close_controls_menu

@onready var jump_remap_row: InputRemapRow = $PanelContainer/VBoxContainer/JumpRemapRow
@onready var dash_remap_row: InputRemapRow = $PanelContainer/VBoxContainer/DashRemapRow
@onready var input_capture_popup: InputCapturePopup = $InputCapturePopup
@onready var return_button: CustomMenuButton = $PanelContainer/VBoxContainer/ReturnButton

var remap_rows: Array[InputRemapRow] = []
var current_remap_row: InputRemapRow = null

func _ready() -> void:
	input_capture_popup.input_captured.connect(_on_input_capture_popup_input_captured)
	input_capture_popup.capture_cancelled.connect(_on_capture_cancelled)
	
	remap_rows = [
		jump_remap_row,
		dash_remap_row,
	]
	
	for row in remap_rows:
		row.remap_requested.connect(_on_remap_requested)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_controls_menu.emit()
		UIAudioManager.play_ui_cancel_sfx()
		get_viewport().set_input_as_handled()

func _on_remap_requested(row: InputRemapRow) -> void:
	for remap_row in remap_rows:
		remap_row.set_remap_enabled(false)
	
	current_remap_row = row
	input_capture_popup.open(row.action_label)

func _on_input_capture_popup_input_captured(event: InputEvent) -> void:
	if current_remap_row == null:
		return
	
	current_remap_row.apply_remap_event(event)
	SaveManager.save_input_map()
	
	for remap_row in remap_rows:
		remap_row.set_remap_enabled(true)
		remap_row.refresh_binding_display()
	
	if current_remap_row:
		current_remap_row.grab_silent_focus()
	
	current_remap_row = null

func _on_capture_cancelled() -> void:
	for remap_row in remap_rows:
		remap_row.set_remap_enabled(true)
		remap_row.refresh_binding_display()
	
	if current_remap_row:
		current_remap_row.grab_silent_focus()
	
	current_remap_row = null


func _on_visibility_changed() -> void:
	if visible:
		jump_remap_row.grab_silent_focus()


func _on_return_button_pressed() -> void:
	close_controls_menu.emit()
