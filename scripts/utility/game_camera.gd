extends Node2D
class_name GameCamera

enum CameraMode {
	FOLLOW,
	FIXED
}

@export var mode: CameraMode = CameraMode.FOLLOW
@export var target: Node2D
@export var follow_smoothing: float = 8.0
@export var fixed_position: Vector2 = Vector2.ZERO
@export var shake_decay: float = 18.0

@onready var camera: Camera2D = $Camera2D

var shake_strength: float = 0.0
var zoom_tween: Tween
var fixed_camera_level: bool = false

func _ready() -> void:
	global_position = get_base_position()
	
	if mode == CameraMode.FIXED:
		fixed_camera_level = true


func _process(delta: float) -> void:
	update_base_position(delta)
	update_shake(delta)


func update_base_position(delta: float) -> void:
	var target_position := get_base_position()

	if mode == CameraMode.FOLLOW:
		global_position = global_position.lerp(target_position, follow_smoothing * delta)
	else:
		global_position = target_position


func get_base_position() -> Vector2:
	match mode:
		CameraMode.FOLLOW:
			if target:
				return target.global_position
			return global_position

		CameraMode.FIXED:
			return fixed_position

	return global_position


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
