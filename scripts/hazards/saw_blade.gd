extends Path2D

@export var rotation_speed : float = 600.0
@export var moving : bool = false
@export var loop : bool = true
@export var speed : float = 2.0
@export var speed_scale : float = 1.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard: Area2D = $Hazard


func _ready() -> void:
	if not moving:
		return
	
	if not curve:
		return
	
	if not loop:
		animation_player.play("move")
		animation_player.speed_scale = speed_scale

func _process(delta: float) -> void:
	hazard.rotation_degrees += rotation_speed * delta
