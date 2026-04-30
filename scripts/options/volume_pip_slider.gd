extends Control
class_name VolumePipSlider

signal value_changed(value: int)

@export var label_text: String = "SFX"
@export_range(0, 5) var value: int = 3


@onready var bus_label_wrapper: Control = $HBoxContainer/BusLabelWrapper
@onready var indicator: TextureRect = $HBoxContainer/BusLabelWrapper/Indicator
@onready var bus_label: Label = $HBoxContainer/BusLabelWrapper/BusLabel
@onready var pip_container: HBoxContainer = $HBoxContainer/PipContainer
@onready var pips: Array[TextureRect] = [
	$HBoxContainer/PipContainer/Pip1,
	$HBoxContainer/PipContainer/Pip2,
	$HBoxContainer/PipContainer/Pip3,
	$HBoxContainer/PipContainer/Pip4,
	$HBoxContainer/PipContainer/Pip5,
]

const INDICATOR_ROTATION_SPEED : float = 350.0
const ACTIVE_PIP_TEXTURE : Texture = preload("uid://bd13td5agwfw6")
const INACTIVE_PIP_TEXTURE : Texture = preload("uid://seqdmyej1pwt")
const FOCUSED_SIZE: Vector2 = Vector2(1.4, 1.4)
const LABEL_FOCUSED_COLOR : Color = "#ffec27"
const ROTATION_OPTIONS: Array[float] = [-2.0, 2.0]

var active: bool = false

var bus_label_tween: Tween

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	bus_label.text = label_text
	call_deferred("update_pivot")
	update_display()
	
	for pip in pips:
		pip.pivot_offset = pip.size / 2

func update_pivot() -> void:
	bus_label_wrapper.pivot_offset = bus_label_wrapper.size / 2.0
	indicator.pivot_offset = indicator.size / 2.0
	pip_container.pivot_offset = pip_container.size / 2.0

func _process(delta: float) -> void:
	indicator.rotation_degrees += INDICATOR_ROTATION_SPEED * delta

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	
	if event.is_action_pressed("ui_left"):
		change_value(-1)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_right"):
		change_value(1)
		get_viewport().set_input_as_handled()


func change_value(amount: int) -> void:
	var old_value := value
	value = clampi(value + amount, 0, 5)
	
	if value == old_value:
		return
	
	if old_value < value:
		pip_tween(pips[value - 1], true)
	else:
		pip_tween(pips[value], false)
	
	update_display()
	value_changed.emit(value)


func update_display() -> void:
	for i in pips.size():
		if i < value:
			pips[i].texture = ACTIVE_PIP_TEXTURE
		else:
			pips[i].texture = INACTIVE_PIP_TEXTURE

func pip_tween(pip: TextureRect, become_active: bool) -> void:
	if pip.scale != Vector2.ONE:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var max_scale : Vector2
	match become_active:
		true:
			max_scale = Vector2(1.2, 1.2)
		false:
			max_scale = Vector2(0.8, 0.8)
	
	pip.scale = max_scale
	pip.rotation_degrees = 15
	
	tween.tween_property(pip, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(pip, "rotation_degrees", 0.0, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_focus_entered() -> void:
	active = true
	
	if bus_label_tween:
		bus_label_tween.kill()
	
	bus_label_tween = create_tween()
	bus_label_tween.set_parallel(true)
	bus_label_tween.tween_property(bus_label_wrapper, "scale", FOCUSED_SIZE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label_tween.tween_property(bus_label_wrapper, "rotation_degrees", ROTATION_OPTIONS.pick_random(), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label_tween.tween_property(pip_container, "scale", FOCUSED_SIZE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label.add_theme_color_override("font_color", LABEL_FOCUSED_COLOR)
	
	indicator.texture = SkinDatabase.retrieve_skin_texture("player", SaveManager.save_data.cosmetics.selected_player_skin)
	
	indicator.modulate.a = 1.0


func _on_focus_exited() -> void:
	active = false
	
	if bus_label_tween:
		bus_label_tween.kill()
	
	bus_label_tween = create_tween()
	bus_label_tween.set_parallel(true)
	bus_label_tween.tween_property(bus_label_wrapper, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label_tween.tween_property(bus_label_wrapper, "rotation_degrees", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label_tween.tween_property(pip_container, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bus_label.add_theme_color_override("font_color", Color.WHITE)
	
	indicator.modulate.a = 0.0
	
