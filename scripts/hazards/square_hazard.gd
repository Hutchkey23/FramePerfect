extends Path2D

@export var rotation_speed : float = 600.0
@export var moving : bool = false
@export var loop : bool = true
@export var speed : float = 2.0
@export var speed_scale : float = 1.0
@export var offset : float = 0.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard: Area2D = $Hazard


func _ready() -> void:
	if not moving:
		return
	
	if not curve:
		return
	
	var anim_length : float = animation_player.get_animation("move").length
	var wrapped_offset: float = fposmod(offset, anim_length)
	
	if not loop:
		animation_player.play("move")
		animation_player.speed_scale = speed_scale
		animation_player.seek(wrapped_offset, true)

func _process(delta: float) -> void:
	hazard.rotation_degrees += rotation_speed * delta
