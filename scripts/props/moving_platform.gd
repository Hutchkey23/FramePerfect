@tool
extends Path2D
class_name MovingPlatformPath

@export var moving: bool = false
@export var loop: bool = true
@export var speed: float = 600.0
@export var speed_scale: float = 1.0

@export var offset: float = 0.0:
	set(value):
		offset = value
		_update_editor_preview()

@export var starting_progress: float = 0.0:
	set(value):
		starting_progress = value
		_update_editor_preview()

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_global_position: Vector2
var movement_delta: Vector2 = Vector2.ZERO


func _ready() -> void:
	last_global_position = global_position

	_update_editor_preview()

	if Engine.is_editor_hint():
		return

	if not moving:
		return

	if not loop:
		var anim := animation_player.get_animation("move")
		if anim == null:
			return

		var anim_length: float = anim.length
		var full_pingpong_length: float = anim_length * 2.0
		var wrapped_offset: float = fposmod(offset, full_pingpong_length)

		if wrapped_offset <= anim_length:
			animation_player.play("move")
			animation_player.speed_scale = speed_scale
			animation_player.seek(wrapped_offset, true)
		else:
			var backward_time: float = anim_length - (wrapped_offset - anim_length)
			animation_player.play_backwards("move")
			animation_player.speed_scale = speed_scale
			animation_player.seek(backward_time, true)
	else:
		if not curve:
			return

		path.loop = true
		path.progress = starting_progress


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_editor_preview()
		return

	if not moving:
		return

	if not loop:
		return

	if not curve:
		return

	if not path:
		return

	path.progress += speed * delta


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	movement_delta = global_position - last_global_position
	last_global_position = global_position


func _update_editor_preview() -> void:
	if not Engine.is_editor_hint():
		return

	if not is_inside_tree():
		return

	var path_follow := get_node_or_null("PathFollow2D") as PathFollow2D
	if path_follow == null:
		return

	if loop:
		path_follow.progress = starting_progress
	else:
		var anim_player := get_node_or_null("AnimationPlayer") as AnimationPlayer
		if anim_player == null:
			return

		var anim := anim_player.get_animation("move")
		if anim == null:
			return

		var anim_length: float = anim.length
		var full_pingpong_length: float = anim_length * 2.0
		var wrapped_offset: float = fposmod(offset, full_pingpong_length)

		if wrapped_offset <= anim_length:
			anim_player.play("move")
			anim_player.seek(wrapped_offset, true)
		else:
			var backward_time: float = anim_length - (wrapped_offset - anim_length)
			anim_player.play_backwards("move")
			anim_player.seek(backward_time, true)
		
		anim_player.pause()
