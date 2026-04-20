extends Node2D

var rotation_speed : float = 20.0
var min_scale : float = 0.25
var max_scale : float = 0.60

var animation_timer : float = 0.75
var min_animation_length : float = 0.20
var max_animation_length : float = 0.35

var dust_cloud_travel_length : float = 0.40
var min_travel_length : float = 0.20
var max_travel_length : float

var end_animation_started : bool = false

func _ready() -> void:
	var random_scale_factor = randf_range(min_scale, max_scale)
	scale *= random_scale_factor
	animation_timer = randf_range(min_animation_length, max_animation_length)

func _process(delta: float) -> void:
	rotation_degrees += rotation_speed
	animation_timer -= delta
	
	if animation_timer <= 0.0:
		play_end_animation()

func move_to(movement_distance: float, movement_direction: Vector2) -> void:
	var tween = create_tween()
	
	var target_position : Vector2 = position + movement_direction.normalized() * movement_distance
	
	tween.tween_property(self, "position", target_position, animation_timer).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func play_end_animation() -> void:
	if end_animation_started:
		return
	
	end_animation_started = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.35).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	
	queue_free()
