extends Area2D
class_name ShakyPlatform

@export var shake_duration: float = 0.35
@export var pause_duration: float = 0.15
@export var fall_duration: float = 0.18
@export var shake_amount: float = 1.5

@onready var shaky_platform_sprite: Sprite2D = $ShakyPlatformSprite
@onready var shaky_platform_collision: CollisionShape2D = $ShakyPlatformCollision


var triggered: bool = false
var start_position: Vector2
var fall_tween: Tween


func _ready() -> void:
	start_position = position
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	
	if not body.is_in_group("player"):
		return
	
	triggered = true
	start_fall_sequence()


func start_fall_sequence() -> void:
	if fall_tween:
		fall_tween.kill()

	fall_tween = create_tween()

	# Tiny shake
	var shake_steps := 8
	var step_duration := shake_duration / float(shake_steps)

	for i in shake_steps:
		var offset := Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)

		fall_tween.tween_property(
			self,
			"position",
			start_position + offset,
			step_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fall_tween.tween_property(
		self,
		"position",
		start_position,
		0.04
	)

	# Brief pause before falling
	fall_tween.tween_interval(pause_duration)

	# Disable safety/collision before it vanishes
	fall_tween.tween_callback(disable_platform)

	# "Fall" by shrinking away
	fall_tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		fall_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	fall_tween.tween_callback(queue_free)


func disable_platform() -> void:
	shaky_platform_collision.disabled = true
	monitoring = false
	monitorable = false
