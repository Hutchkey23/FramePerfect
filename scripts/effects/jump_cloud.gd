extends Node2D

@onready var jump_cloud_sprite: Sprite2D = $JumpCloudSprite

const TOTAL_FRAMES : int = 6
const FRAME_CHANGE_LENGTH : float = 0.025
const JUMP_CLOUD_SCALE : float = 0.5
var frame_change_timer : float

const ROTATION_SPEED : float = 200.0

func _ready() -> void:
	scale = Vector2.ONE * JUMP_CLOUD_SCALE
	frame_change_timer = FRAME_CHANGE_LENGTH

func _process(delta: float) -> void:
	rotation_degrees += ROTATION_SPEED * delta
	
	frame_change_timer -= delta
	
	if frame_change_timer <= 0.0:
		change_frame()

func change_frame() -> void:
	if jump_cloud_sprite.frame == TOTAL_FRAMES - 1:
		queue_free()
	else:
		jump_cloud_sprite.frame += 1
		frame_change_timer = FRAME_CHANGE_LENGTH
