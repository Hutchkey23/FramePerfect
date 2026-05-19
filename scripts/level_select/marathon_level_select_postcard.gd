extends Control
class_name MarathonPostcard

signal exit_world
signal marathon_selected(data: MarathonData)

@export var flip_time: float = 0.16
@export var marathon_data: MarathonData

# Front
@onready var front: PanelContainer = $Front

@onready var postcard_front_texture: TextureRect = $Front/PostcardFrontTexture
@onready var world_number_label: Label = $Front/VBoxContainer/WorldNumberLabelMarginContainer/WorldNumberLabel
@onready var world_title_label: Label = $Front/VBoxContainer/WorldTitleLabelMarginContainer/WorldTitleLabel


# Back
@onready var back: PanelContainer = $Back

@onready var postcard_back_texture: TextureRect = $Back/PostcardBackTexture
@onready var world_back_title_label: Label = $Back/VBoxContainer/MarginContainer/WorldBackTitleLabel
@onready var best_time_text_label: Label = $Back/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/BestTimeTextLabel
@onready var best_time_label: Label = $Back/VBoxContainer/HBoxContainer/VBoxContainer/BestTimeAndMedalContainer/BestTimeLabel
@onready var medal_time_text_label: Label = $Back/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MedalTimeTextLabel
@onready var medal_time_label: Label = $Back/VBoxContainer/HBoxContainer/VBoxContainer2/MedalTimeContainer/MedalTimeLabel
@onready var medal_slot: TextureRect = $Back/MedalContainer/MedalSlot

const MEDAL_FILLED_TEXTURE: Texture = preload("uid://bwwkja68c8teb")
const MEDAL_EMPTY_TEXTURE: Texture = preload("uid://y2p73lbkpyg2")

var levels_array: Array[LevelData]
var current_world_index: int = 0
var current_level_index: int = 0

var is_flipped: bool = false

#### Tweens/Animation ####
const ROTATION_AMOUNT: float = 2.0
const ROTATION_SPEED: float = 4.0

var flip_tween: Tween

var left_arrow_tween: Tween
var right_arrow_tween: Tween

var level_title_jump_tween: Tween
var level_number_jump_tween: Tween
################
var labels: Array[Label]

var time: float = 0.0

func _ready() -> void:
	pivot_offset = size / 2
	
	labels = [
		world_number_label,
		world_title_label,
		world_back_title_label,
		best_time_text_label,
		best_time_label,
		medal_time_text_label,
		medal_time_label
	]

	front.visible = true
	back.visible = false
	is_flipped = false
	
	setup(marathon_data)
	
	setup_pivots()
	
	await get_tree().process_frame

func _process(delta: float) -> void:
	time += delta
	world_back_title_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	best_time_text_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	best_time_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	medal_time_text_label.rotation_degrees = -sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	medal_time_label.rotation_degrees = -sin(time * ROTATION_SPEED) * ROTATION_AMOUNT

func setup(data: MarathonData) -> void:
	world_number_label.text = "WORLD " + str(data.world_number)
	
	if data.world_number == 0:
		world_number_label.visible = false
		world_title_label.custom_minimum_size.y = 16.0
	
	world_title_label.text = data.display_name
	world_back_title_label.text = data.display_name
	
	var medal_earned: bool = SaveManager.player_has_marathon_medal(
	data.marathon_id,
	data.medal_time
	)
	set_medal_slot(medal_earned)
	
	var best_time: float = SaveManager.get_best_marathon_time(data.marathon_id)	
	var medal_time: float = data.medal_time
	
	best_time_label.text = SaveManager.format_time(best_time)
	medal_time_label.text = SaveManager.format_time(medal_time)
	
	postcard_front_texture.texture = data.front_image
	postcard_back_texture.texture = data.back_image
	set_font_color(data.font_color)

func _unhandled_input(event: InputEvent) -> void:
	if not is_flipped:
		return
	elif event.is_action_pressed("ui_cancel"):
		exit_world.emit(self)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		UIAudioManager.play_ui_confirm_sfx()
		marathon_selected.emit(marathon_data)

#region Back of Postcard
func _move_selection(direction: int) -> void:
	var new_index := clampi(current_level_index + direction, 0, levels_array.size() - 1)

	if new_index == current_level_index:
		return
	
	UIAudioManager.play_ui_pip_sfx()
	
	current_level_index = new_index
	
	
#endregion

#region Helpers
func setup_pivots() -> void:
	for label in labels:
		label.pivot_offset = label.size / 2

func set_font_color(chosen_color: Color):
	for label in labels:
		label.add_theme_color_override("font_color", chosen_color)

func set_medal_slot(medal_filled: bool) -> void:
	match medal_filled:
		true:
			medal_slot.texture = MEDAL_FILLED_TEXTURE
		false:
			medal_slot.texture = MEDAL_EMPTY_TEXTURE

func get_display_number(level_id: String) -> String:
	var num := int(level_id.split("_")[1])
	return str(num).pad_zeros(2)
#endregion

#region Animation
func flip_to_back() -> void:
	if is_flipped:
		return
	
	current_level_index = 0
	
	is_flipped = true
	_flip(true)


func flip_to_front() -> void:
	if not is_flipped:
		return
	
	is_flipped = false
	_flip(false)


func toggle_flip() -> void:
	is_flipped = not is_flipped
	_flip(is_flipped)


func _flip(show_back: bool) -> void:
	if flip_tween:
		flip_tween.kill()

	var original_scale := scale
	var thin_scale := Vector2(0.04, original_scale.y)

	flip_tween = create_tween()
	flip_tween.set_trans(Tween.TRANS_QUAD)
	flip_tween.set_ease(Tween.EASE_IN_OUT)

	flip_tween.tween_property(self, "scale", thin_scale, flip_time)

	flip_tween.tween_callback(func():
		front.visible = not show_back
		back.visible = show_back
	)

	flip_tween.tween_property(self, "scale", original_scale, flip_time)

func _setup_label_pivots() -> void:
	world_back_title_label.pivot_offset = world_back_title_label.size / 2
	world_number_label.pivot_offset = world_number_label.size / 2

#endregion
