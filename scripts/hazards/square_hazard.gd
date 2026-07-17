@tool
extends Path2D
class_name SquareHazard


@export_category("Movement")

@export var moving: bool = false
@export var loop: bool = true
@export var easing: bool = true

@export var speed: float = 600.0
@export var speed_scale: float = 1.0

@export var offset: float = 0.0
@export var starting_progress: float = 0.0


@export_category("Rotation")

@export var rotation_speed: float = 600.0
@export var should_not_rotate: bool = false


@export_category("Editor Preview")

@export var preview_in_editor: bool = true

@export_tool_button("Reset Preview")
var reset_preview_button := reset_preview


@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard: Area2D = $Hazard


var editor_pingpong_time: float = 0.0
var editor_initialized: bool = false


func _ready() -> void:
	if not moving:
		return

	if curve == null:
		return

	if Engine.is_editor_hint():
		initialize_editor_preview()
		return

	initialize_runtime_movement()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		process_editor_preview(delta)
		return

	process_runtime(delta)


func initialize_runtime_movement() -> void:
	if loop:
		path.loop = true
		path.progress += starting_progress
		return

	play_pingpong_animation(offset)


func process_runtime(delta: float) -> void:
	rotate_hazard(delta)

	if not moving:
		return

	if not loop:
		return

	if curve == null:
		return

	path.progress += speed * delta


func initialize_editor_preview() -> void:
	if not is_instance_valid(path):
		return

	path.loop = loop
	path.progress = starting_progress

	editor_pingpong_time = offset
	editor_initialized = true


func process_editor_preview(delta: float) -> void:
	if not preview_in_editor:
		return

	if not is_instance_valid(path):
		return

	if not is_instance_valid(hazard):
		return

	rotate_hazard(delta)

	if not moving:
		return

	if curve == null:
		return

	if not editor_initialized:
		initialize_editor_preview()

	if loop:
		path.loop = true
		path.progress += speed * speed_scale * delta
	else:
		update_editor_pingpong(delta)


func update_editor_pingpong(delta: float) -> void:
	var curve_length := curve.get_baked_length()

	if curve_length <= 0.0:
		return

	var effective_speed := speed * speed_scale
	editor_pingpong_time += effective_speed * delta

	var full_distance := curve_length * 2.0
	var wrapped_distance := fposmod(editor_pingpong_time, full_distance)

	var target_progress: float

	if wrapped_distance <= curve_length:
		target_progress = wrapped_distance
	else:
		target_progress = full_distance - wrapped_distance

	if easing:
		var normalized_progress := target_progress / curve_length
		normalized_progress = ease(normalized_progress, -2.0)
		target_progress = normalized_progress * curve_length

	path.progress = target_progress


func rotate_hazard(delta: float) -> void:
	if should_not_rotate:
		return

	hazard.rotation_degrees += rotation_speed * delta


func play_pingpong_animation(animation_offset: float) -> void:
	var animation_name := "move" if easing else "move_no_ease"
	var animation := animation_player.get_animation(animation_name)

	if animation == null:
		return

	var animation_length := animation.length
	var full_pingpong_length := animation_length * 2.0
	var wrapped_offset := fposmod(animation_offset, full_pingpong_length)

	animation_player.speed_scale = speed_scale

	if wrapped_offset <= animation_length:
		animation_player.play(animation_name)
		animation_player.seek(wrapped_offset, true)
	else:
		var backward_time := animation_length - (
			wrapped_offset - animation_length
		)

		animation_player.play_backwards(animation_name)
		animation_player.seek(backward_time, true)


func reset_preview() -> void:
	if not is_instance_valid(path):
		return

	path.progress = starting_progress

	if is_instance_valid(hazard):
		hazard.rotation_degrees = 0.0

	editor_pingpong_time = offset
	editor_initialized = true
