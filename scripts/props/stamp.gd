extends Area2D
class_name Stamp

signal collected

@onready var stamp_sprite: Sprite2D = $StampSprite

const STAMP_TEXTURES := [
	preload("res://assets/sprites/stamps/stamp1.png"),
	preload("res://assets/sprites/stamps/stamp2.png"),
	preload("res://assets/sprites/stamps/stamp3.png"),
	preload("res://assets/sprites/stamps/stamp4.png"),
	preload("res://assets/sprites/stamps/stamp5.png"),
	preload("res://assets/sprites/stamps/stamp6.png"),
	preload("res://assets/sprites/stamps/stamp7.png"),
	preload("res://assets/sprites/stamps/stamp8.png"),
	preload("res://assets/sprites/stamps/stamp9.png"),
	preload("res://assets/sprites/stamps/stamp10.png"),
]

func _ready() -> void:
	stamp_sprite.texture = STAMP_TEXTURES.pick_random()

func _process(_delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() * 0.005) * 0.1
	rotation_degrees = sin(Time.get_ticks_msec() * 0.005) * 8


func collect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	collected.emit(self)
