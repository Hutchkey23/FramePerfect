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
		queue_redraw()

@export var starting_progress: float = 0.0:
	set(value):
		starting_progress = value
		_update_editor_preview()
		queue_redraw()

@export_category("Editor Visualization")
@export var show_preview: bool = true:
	set(value):
		show_preview = value
		queue_redraw()

@export var preview_points: bool = true:
	set(value):
		preview_points = value
		queue_redraw()

@export var preview_platform_size: Vector2 = Vector2(16, 16):
	set(value):
		preview_platform_size = value
		queue_redraw()

@export var preview_path_width: float = 2.0:
	set(value):
		preview_path_width = value
		queue_redraw()

@export var animate_preview: bool = false:
	set(value):
		animate_preview = value
		queue_redraw()

@export var preview_speed: float = 600.0

var editor_preview_progress: float = 0.0
var editor_preview_direction: float = 1.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_global_position: Vector2
var movement_delta: Vector2 = Vector2.ZERO


func _ready() -> void:
	editor_preview_progress = starting_progress
	last_global_position = global_position
	_update_editor_preview()
	queue_redraw()

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
		if animate_preview and curve:
			if loop:
				editor_preview_progress += preview_speed * delta
				editor_preview_progress = fposmod(editor_preview_progress, curve.get_baked_length())
				path.progress = editor_preview_progress
			else:
				var anim := animation_player.get_animation("move")
				if anim:
					editor_preview_progress += preview_speed * delta * editor_preview_direction

					if editor_preview_progress >= anim.length:
						editor_preview_progress = anim.length
						editor_preview_direction = -1.0
					elif editor_preview_progress <= 0.0:
						editor_preview_progress = 0.0
						editor_preview_direction = 1.0

					animation_player.play("move")
					animation_player.seek(editor_preview_progress, true)
					animation_player.pause()

		else:
			_update_editor_preview()

		queue_redraw()
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


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	if not show_preview:
		return

	if curve == null:
		return

	var baked_points := curve.get_baked_points()
	if baked_points.size() < 2:
		return

	for i in range(baked_points.size() - 1):
		draw_line(
			baked_points[i],
			baked_points[i + 1],
			Color.YELLOW,
			preview_path_width
		)

	if preview_points:
		for point in baked_points:
			draw_circle(point, 2.0, Color.WHITE)

	var preview_progress := editor_preview_progress if animate_preview else starting_progress

	if not loop:
		var anim := animation_player.get_animation("move") if animation_player else null
		if anim:
			var anim_length: float = anim.length
			var full_pingpong_length: float = anim_length * 2.0
			var wrapped_offset: float = fposmod(offset, full_pingpong_length)

			if wrapped_offset <= anim_length:
				preview_progress = wrapped_offset
			else:
				preview_progress = anim_length - (wrapped_offset - anim_length)

	var preview_position := curve.sample_baked(preview_progress)

	draw_circle(preview_position, 4.0, Color.LIME_GREEN)

	var ghost_rect := Rect2(
		preview_position - preview_platform_size * 0.5,
		preview_platform_size
	)

	draw_rect(ghost_rect, Color(0.2, 1.0, 0.2, 0.35), true)
	draw_rect(ghost_rect, Color.LIME_GREEN, false, 2.0)
