extends Control

@onready var logo_container: MarginContainer = $VBoxContainer/LogoContainer
@onready var play_button: CustomMenuButton = $VBoxContainer/PlayButton

const ROTATION_AMOUNT: float = 2.0
const ROTATION_SPEED: float = 2.0

var time: float = 0.0

func _ready() -> void:
	call_deferred("setup_pivots")
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
