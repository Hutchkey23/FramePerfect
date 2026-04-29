extends Control

@export var postcard_spacing: float = 260.0
@export var tween_time: float = 0.36

const POSTCARD_SELECTED_SCALE: Vector2 = Vector2(1.6, 1.6)
const POSTCARD_NOT_SELECTED_SCALE: Vector2 = Vector2(1.2, 1.2)

@onready var postcard_holder: Control = $PostcardHolder

@onready var postcards: Array[Postcard] = [
	$PostcardHolder/PeacefulPlainsPostcard,
	$PostcardHolder/ScorchedSandsPostcard,
	$PostcardHolder/FrostedFrontierPostcard,
	$PostcardHolder/GalacticGatewayPostcard
]

var current_world_index: int = 0
var move_tween: Tween

var postcard_selected: bool = false

func _ready() -> void:
	_position_postcards()
	_update_selection(false)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if postcard_selected:
		return
	
	if event.is_action_pressed("ui_left"):
		_move_selection(-1)
	elif event.is_action_pressed("ui_right"):
		_move_selection(1)
	elif event.is_action_pressed("ui_accept"):
		_confirm_world()


func _position_postcards() -> void:
	for i in postcards.size():
		postcards[i].position = Vector2(i * postcard_spacing, 0.0)


func _move_selection(direction: int) -> void:
	var new_index := clampi(current_world_index + direction, 0, postcards.size() - 1)

	if new_index == current_world_index:
		return

	current_world_index = new_index
	_update_selection(true)


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


func _confirm_world() -> void:
	postcard_selected = true
	var world_number := current_world_index + 1
	var selected_card : Postcard = postcards[current_world_index]
	selected_card.flip_to_back()
