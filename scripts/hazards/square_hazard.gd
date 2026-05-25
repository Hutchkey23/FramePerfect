extends Path2D

@export var rotation_speed : float = 600.0
@export var moving : bool = false
@export var easing : bool = true
@export var loop : bool = true
@export var speed : float = 600.0
@export var speed_scale : float = 1.0
@export var offset : float = 0.0
@export var starting_progress: float = 0.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard: Area2D = $Hazard


func _ready() -> void:
	if not moving:
		return
	
	if not curve:
		return
	
	if not loop:
		var anim := animation_player.get_animation("move")
		if anim == null:
			return
		
		var anim_length := anim.length
		var full_pingpong_length := anim_length * 2.0
		var wrapped_offset := fposmod(offset, full_pingpong_length)
		
		if wrapped_offset <= anim_length:
			# Forward half
			if easing:
				animation_player.play("move")
			else:
				animation_player.play("move_no_ease")
			animation_player.speed_scale = speed_scale
			animation_player.seek(wrapped_offset, true)
		else:
			# Backward half
			var backward_time := anim_length - (wrapped_offset - anim_length)
			if easing:
				animation_player.play_backwards("move")
			else:
				animation_player.play_backwards("move_no_ease")
			animation_player.speed_scale = speed_scale
			animation_player.seek(backward_time, true)
	else:
		path.loop = true
		path.progress += starting_progress

func _process(delta: float) -> void:
	hazard.rotation_degrees += rotation_speed * delta
	
	if not moving:
		return
	
	if not loop:
		return
	
	if not curve:
		return
	
	path.progress += speed * delta
