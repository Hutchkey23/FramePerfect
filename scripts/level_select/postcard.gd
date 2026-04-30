extends Control
class_name Postcard

signal exit_world
signal level_selected(world_index, level_index)

@export var flip_time: float = 0.16
@export var world_data: WorldData

# Front
@onready var front: PanelContainer = $Front

@onready var postcard_front_texture: TextureRect = $Front/PostcardFrontTexture
@onready var world_number_label: Label = $Front/VBoxContainer/WorldNumberLabelMarginContainer/WorldNumberLabel
@onready var world_title_label: Label = $Front/VBoxContainer/WorldTitleLabelMarginContainer/WorldTitleLabel


# Back
@onready var back: PanelContainer = $Back

@onready var postcard_back_texture: TextureRect = $Back/PostcardBackTexture
@onready var level_title_label: Label = $Back/VBoxContainer/MarginContainer/LevelTitleLabel
@onready var left_arrow: Label = $Back/VBoxContainer/HBoxContainer/LeftArrow
@onready var level_number_label: Label = $Back/VBoxContainer/HBoxContainer/LevelNumberLabel
@onready var right_arrow: Label = $Back/VBoxContainer/HBoxContainer/RightArrow
@onready var best_time_text_label: Label = $Back/VBoxContainer/MarginContainer2/BestTimeTextLabel
@onready var best_time_label: Label = $Back/VBoxContainer/BestTimeAndMedalContainer/BestTimeLabel
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
		level_title_label,
		left_arrow,
		level_number_label,
		right_arrow,
		best_time_text_label,
		best_time_label
	]

	front.visible = true
	back.visible = false
	is_flipped = false
	
	setup(world_data)
	
	setup_pivots()
	
	await get_tree().process_frame

func _process(delta: float) -> void:
	time += delta
	level_title_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	level_number_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	best_time_text_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT
	best_time_label.rotation_degrees = sin(time * ROTATION_SPEED) * ROTATION_AMOUNT

func setup(data: WorldData) -> void:
	world_data = data

	world_number_label.text = "WORLD " + str(data.world_number)
	world_title_label.text = data.world_title
	postcard_front_texture.texture = data.front_image
	postcard_back_texture.texture = data.back_image
	set_font_color(data.font_color)
	
	levels_array = data.levels
	update_level_display()

func _unhandled_input(event: InputEvent) -> void:
	if not is_flipped:
		return
	if event.is_action_pressed("ui_left"):
		_move_selection(-1)
	elif event.is_action_pressed("ui_right"):
		_move_selection(1)
	elif event.is_action_pressed("ui_cancel"):
		exit_world.emit(self)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		level_selected.emit(current_world_index, current_level_index)

#region Back of Postcard
func _move_selection(direction: int) -> void:
	var new_index := clampi(current_level_index + direction, 0, levels_array.size() - 1)

	if new_index == current_level_index:
		return
	
	current_level_index = new_index
	
	play_arrow_animation(direction)
	
	update_level_display()

func update_level_display() -> void:
	if levels_array.size() <= 0:
		return

	var level_data: LevelData = levels_array[current_level_index]
	var level_id = level_data.level_id
	level_title_label.text = level_data.level_title
	
	var level_number = get_display_number(level_id)
	level_number_label.text = level_number
	
	var medal_earned: bool = SaveManager.player_has_medal(level_id)
	set_medal_slot(medal_earned)
	
	var best_time: float = SaveManager.get_best_time(level_id)
	
	if best_time < 9999.0:
		best_time_label.text = "%.2f" % best_time
	else:
		best_time_label.text = "--.--"
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
	update_level_display()
	
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

func play_arrow_animation(arrow_direction: int) -> void:
	if left_arrow_tween:
		left_arrow_tween.kill()
	if right_arrow_tween:
		right_arrow_tween.kill()

	var offset := 8.0
	var duration := 0.06

	match arrow_direction:
		-1:
			var start_pos := left_arrow.position
			var target_pos := start_pos + Vector2(-offset, 0)

			left_arrow_tween = create_tween()
			left_arrow_tween.set_trans(Tween.TRANS_QUAD)
			left_arrow_tween.set_ease(Tween.EASE_OUT)

			left_arrow_tween.tween_property(left_arrow, "position", target_pos, duration)
			left_arrow_tween.tween_property(left_arrow, "position", start_pos, duration)

		1:
			var start_pos := right_arrow.position
			var target_pos := start_pos + Vector2(offset, 0)

			right_arrow_tween = create_tween()
			right_arrow_tween.set_trans(Tween.TRANS_QUAD)
			right_arrow_tween.set_ease(Tween.EASE_OUT)

			right_arrow_tween.tween_property(right_arrow, "position", target_pos, duration)
			right_arrow_tween.tween_property(right_arrow, "position", start_pos, duration)

func _setup_label_pivots() -> void:
	level_title_label.pivot_offset = level_title_label.size / 2
	level_number_label.pivot_offset = level_number_label.size / 2

#endregion
