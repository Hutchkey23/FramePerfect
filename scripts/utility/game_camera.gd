@tool
extends Node2D
class_name GameCamera

enum CameraMode {
	FOLLOW,
	FIXED
}

@export var mode: CameraMode = CameraMode.FOLLOW
@export var target: Node2D
@export var default_zoom: Vector2 = Vector2.ONE
@export var follow_smoothing: float = 8.0
@export var fixed_position: Vector2 = Vector2.ZERO
@export var shake_decay: float = 18.0

@export var use_bounds: bool = false:
	set(value):
		use_bounds = value
		queue_redraw()

@export var bounds: Rect2:
	set(value):
		bounds = value
		queue_redraw()

@export var show_bounds_in_editor: bool = true:
	set(value):
		show_bounds_in_editor = value
		queue_redraw()

@onready var camera: Camera2D = $Camera2D

var shake_strength: float = 0.0
var zoom_tween: Tween
var fixed_camera_level: bool = false

func _ready() -> void:
	camera.zoom = default_zoom
	global_position = get_base_position()
	
	if mode == CameraMode.FIXED:
		fixed_camera_level = true
	else:
		if camera.zoom == Vector2.ONE:
			camera.zoom = Vector2(0.8, 0.8)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	if show_bounds_in_editor and use_bounds:
		draw_rect(bounds, Color.WHITE, false, 2.0)

	draw_camera_zoom_preview()


func draw_camera_zoom_preview() -> void:
	if camera == null:
		return

	var preview_center := get_base_position()
	var viewport_size := get_viewport_rect().size
	var visible_size := viewport_size / camera.zoom

	var rect := Rect2(
		to_local(preview_center - visible_size * 0.5),
		visible_size
	)

	draw_rect(rect, Color.YELLOW, false, 2.0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		camera.zoom = default_zoom

		if mode == CameraMode.FIXED:
			global_position = fixed_position
		elif target:
			global_position = target.global_position

		queue_redraw()
		return

	update_base_position(delta)
	update_shake(delta)

func update_base_position(delta: float) -> void:
	var target_position := get_base_position()

	var new_position: Vector2

	if mode == CameraMode.FOLLOW:
		new_position = global_position.lerp(target_position, follow_smoothing * delta)
	else:
		new_position = target_position

	# Clamp if enabled
	new_position = get_clamped_position(new_position)

	global_position = new_position


func get_base_position() -> Vector2:
	match mode:
		CameraMode.FOLLOW:
			if target:
				return target.global_position
			return global_position

		CameraMode.FIXED:
			return fixed_position

	return global_position

func get_clamped_position(pos: Vector2) -> Vector2:
	if not use_bounds:
		return pos
	
	var viewport_size := get_viewport_rect().size
	var half_view := (viewport_size * 0.5) / camera.zoom
	
	var min_pos := bounds.position + half_view
	var max_pos := bounds.end - half_view
	
	# If bounds are smaller than the camera view, center camera in bounds.
	if min_pos.x > max_pos.x:
		pos.x = bounds.get_center().x
	else:
		pos.x = clamp(pos.x, min_pos.x, max_pos.x)
	
	if min_pos.y > max_pos.y:
		pos.y = bounds.get_center().y
	else:
		pos.y = clamp(pos.y, min_pos.y, max_pos.y)
	
	return pos

func update_shake(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)

		var offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		camera.offset = offset
	else:
		camera.offset = Vector2.ZERO


func set_follow_target(new_target: Node2D) -> void:
	target = new_target


func set_mode_follow(new_target: Node2D) -> void:
	mode = CameraMode.FOLLOW
	target = new_target


func set_mode_fixed(new_position: Vector2) -> void:
	mode = CameraMode.FIXED
	fixed_position = new_position
	global_position = fixed_position


func add_shake(amount: float) -> void:
	if not SaveManager.get_option("screen_shake", true):
		return
	
	shake_strength = max(shake_strength, amount)

func zoom_to_target(target_node: Node2D, zoom_amount: Vector2, zoom_duration: float) -> void:
	if zoom_tween:
		zoom_tween.kill()

	if target_node:
		target = target_node
		mode = CameraMode.FOLLOW

	zoom_tween = create_tween()
	zoom_tween.tween_property(camera, "zoom", zoom_amount, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func retry_level() -> void:
	if zoom_tween:
		zoom_tween.kill()
	
	camera.zoom = Vector2.ONE
	
	if fixed_camera_level:
		set_mode_fixed(fixed_position)
