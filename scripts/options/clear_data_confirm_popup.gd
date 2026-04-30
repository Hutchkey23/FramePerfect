extends Control

signal cancel_button_pressed
signal confirm_button_pressed

@onready var confirm_button: CustomMenuButton = $PanelContainer/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_button: CustomMenuButton = $PanelContainer/VBoxContainer/HBoxContainer/CancelButton



func _on_confirm_button_pressed() -> void:
	confirm_button_pressed.emit()


func _on_cancel_button_pressed() -> void:
	cancel_button_pressed.emit()
