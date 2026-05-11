extends Control
class_name LevelSelect

signal exit_level_select
signal level_selected(world_index: int, level_index: int)

@export var postcard_spacing: float = 260.0
@export var tween_time: float = 0.36

const POSTCARD_SELECTED_SCALE: Vector2 = Vector2(1.6, 1.6)
const POSTCARD_NOT_SELECTED_SCALE: Vector2 = Vector2(1.2, 1.2)

@onready var postcard_holder: Control = $PostcardHolder
@onready var left_arrow: Control = $LeftArrow
@onready var right_arrow: Control = $RightArrow

@onready var postcards: Array[Postcard] = [
	$PostcardHolder/PeacefulPlainsPostcard,
	$PostcardHolder/ScorchedSandsPostcard,
	$PostcardHolder/FrostedFrontierPostcard,
	$PostcardHolder/GalacticGatewayPostcard
]

@onready var peaceful_plains_background: TextureRect = $BackgroundHolder/PeacefulPlainsBackground
@onready var scorched_sands_background: TextureRect = $BackgroundHolder/ScorchedSandsBackground
@onready var frosted_frontier_background: TextureRect = $BackgroundHolder/FrostedFrontierBackground
@onready var galactic_gateway_background: TextureRect = $BackgroundHolder/GalacticGatewayBackground


var backgrounds: Array[TextureRect] = []

var navigation_arrows: Array[Control] = []

var current_world_index: int = 0
var current_background_index: int = 0
var move_tween: Tween
var left_arrow_tween: Tween
var right_arrow_tween: Tween

var left_arrow_start_pos: Vector2
var right_arrow_start_pos: Vector2
var left_arrow_idle_tween: Tween
var right_arrow_idle_tween: Tween

var postcard_selected: bool = false

var background_tween: Tween

func _ready() -> void:
	navigation_arrows = [left_arrow, right_arrow]
	backgrounds = [
		peaceful_plains_background,
		scorched_sands_background,
		frosted_frontier_background,
		galactic_gateway_background
	]
	
	for i in backgrounds.size():
		var bg := backgrounds[i]
		var mat := bg.material as ShaderMaterial

		if i == current_world_index:
			mat.set_shader_parameter("fade_alpha", 1.0)
			bg.move_to_front()
		else:
			mat.set_shader_parameter("fade_alpha", 0.0)

	current_background_index = current_world_index
	
	_position_postcards()
	_update_selection(false)
	update_arrows()
	
	left_arrow_start_pos = left_arrow.position
	right_arrow_start_pos = right_arrow.position

	_start_arrow_idle_animation(left_arrow, -1)
	_start_arrow_idle_animation(right_arrow, 1)
	
	for i in postcards.size():
		postcards[i].exit_world.connect(on_exit_world)
		postcards[i].level_selected.connect(on_level_selected)
		postcards[i].current_world_index = i


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if postcard_selected:
		return
	
	if event.is_action_pressed("ui_left"):
		_move_selection(-1)
	elif event.is_action_pressed("ui_right"):
		_move_selection(1)
	elif event.is_action_pressed("ui_cancel"):
		exit_level_select.emit()
		UIAudioManager.play_ui_cancel_sfx()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_world()


func _position_postcards() -> void:
	for i in postcards.size():
		postcards[i].position = Vector2(i * postcard_spacing, 0.0)

func update_arrows() -> void:
	if current_world_index == 0:
		left_arrow.visible = false
	else:
		left_arrow.visible = true
	
	if current_world_index == postcards.size() - 1:
		right_arrow.visible = false
	else:
		right_arrow.visible = true

func _move_selection(direction: int) -> void:
	var new_index := clampi(current_world_index + direction, 0, postcards.size() - 1)

	if new_index == current_world_index:
		return
	
	UIAudioManager.play_ui_slide_sfx()
	current_world_index = new_index
	
	
	play_arrow_animation(direction)
	
	update_arrows()
	update_background()
	_update_selection(true)

func update_background() -> void:
	var old_bg := backgrounds[current_background_index]
	var new_bg := backgrounds[current_world_index]

	if old_bg == new_bg:
		return

	current_background_index = current_world_index

	if background_tween:
		background_tween.kill()

	var old_mat := old_bg.material as ShaderMaterial
	var new_mat := new_bg.material as ShaderMaterial

	# Keep old visible underneath.
	old_mat.set_shader_parameter("fade_alpha", 1.0)

	# Put new background above old background.
	new_bg.move_to_front()
	new_mat.set_shader_parameter("fade_alpha", 0.0)

	background_tween = create_tween()
	background_tween.tween_property(
		new_mat,
		"shader_parameter/fade_alpha",
		1.0,
		0.2
	)

	await background_tween.finished

	# After the new bg fully covers the screen, hide the old backgrounds.
	for bg in backgrounds:
		if bg != new_bg:
			var mat := bg.material as ShaderMaterial
			mat.set_shader_parameter("fade_alpha", 0.0)

func _update_selection(animated: bool) -> void:
	var selected_card := postcards[current_world_index]

	var screen_center_x := size.x * 0.5
	var card_center_x := selected_card.position.x + selected_card.size.x * 0.5
	var target_x := screen_center_x - card_center_x

	if move_tween:
		move_tween.kill()

	if animated:
		move_tween = create_tween()
		move_tween.set_trans(Tween.TRANS_QUAD)
		move_tween.set_ease(Tween.EASE_OUT)
		move_tween.tween_property(postcard_holder, "position:x", target_x, tween_time)
	else:
		postcard_holder.position.x = target_x

	for i in postcards.size():
		_set_postcard_selected(postcards[i], i == current_world_index)

func _set_postcard_selected(card: Control, selected: bool) -> void:
	if card.has_method("set_selected"):
		card.set_selected(selected)
	else:
		card.scale = POSTCARD_SELECTED_SCALE if selected else POSTCARD_NOT_SELECTED_SCALE

func on_exit_world(postcard: Postcard) -> void:
	postcard.flip_to_front()
	postcard_selected = false
	UIAudioManager.play_postcard_flip_to_front_sfx()
	toggle_navigation_arrows(true)

func _confirm_world() -> void:
	postcard_selected = true
	var selected_card : Postcard = postcards[current_world_index]
	selected_card.flip_to_back()
	UIAudioManager.play_postcard_flip_to_back_sfx()
	toggle_navigation_arrows(false)

func on_level_selected(world_index: int, level_index: int) -> void:
	level_selected.emit(world_index, level_index)

func play_arrow_animation(arrow_direction: int) -> void:
	var offset := 10.0
	var duration := 0.06

	match arrow_direction:
		-1:
			if left_arrow_tween:
				left_arrow_tween.kill()

			var target_pos := left_arrow_start_pos + Vector2(-offset, 0)

			left_arrow_tween = create_tween()
			left_arrow_tween.set_trans(Tween.TRANS_QUAD)
			left_arrow_tween.set_ease(Tween.EASE_OUT)
			left_arrow_tween.tween_property(left_arrow, "position", target_pos, duration)
			left_arrow_tween.tween_property(left_arrow, "position", left_arrow_start_pos, duration)

		1:
			if right_arrow_tween:
				right_arrow_tween.kill()

			var target_pos := right_arrow_start_pos + Vector2(offset, 0)

			right_arrow_tween = create_tween()
			right_arrow_tween.set_trans(Tween.TRANS_QUAD)
			right_arrow_tween.set_ease(Tween.EASE_OUT)
			right_arrow_tween.tween_property(right_arrow, "position", target_pos, duration)
			right_arrow_tween.tween_property(right_arrow, "position", right_arrow_start_pos, duration)

func _start_arrow_idle_animation(arrow: Control, direction: int) -> void:
	var start_pos := arrow.position
	var target_pos := start_pos + Vector2(4.0 * direction, 0.0)
	
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(arrow, "position", target_pos, 0.45)
	tween.tween_property(arrow, "position", start_pos, 0.45)
	
	if direction < 0:
		left_arrow_idle_tween = tween
	else:
		right_arrow_idle_tween = tween

func toggle_navigation_arrows(is_showing: bool) -> void:
	for arrow in navigation_arrows:
		arrow.visible = is_showing
	if is_showing:
		update_arrows()


func fade_background_out(background: TextureRect) -> void:
	var mat := background.material as ShaderMaterial
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/fade_alpha", 0.0, 0.25).set_ease(Tween.EASE_OUT)


func fade_background_in(background: TextureRect) -> void:
	var mat := background.material as ShaderMaterial
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/fade_alpha", 1.0, 0.25)
