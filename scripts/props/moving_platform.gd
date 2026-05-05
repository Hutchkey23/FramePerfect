extends Path2D
class_name MovingPlatformPath

@export var moving : bool = false
@export var loop : bool = true
@export var speed : float = 600.0
@export var speed_scale : float = 1.0
@export var offset : float = 0.0
@export var starting_progress: float = 0.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard: Area2D = $Hazard

var last_global_position: Vector2
var movement_delta: Vector2 = Vector2.ZERO


func _ready() -> void:
	last_global_position = global_position
	
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
		path.progress += starting_progress


func _process(delta: float) -> void:
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
	movement_delta = global_position - last_global_position
	last_global_position = global_position
