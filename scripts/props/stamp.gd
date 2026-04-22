extends Area2D
class_name Stamp

signal collected

@onready var stamp_sprite: Sprite2D = $StampSprite

#func _ready() -> void:
	#await get_tree().create_timer(5).timeout
	#collect()

func _process(_delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() * 0.005) * 0.1
	rotation_degrees = sin(Time.get_ticks_msec() * 0.005) * 8


func collect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	collected.emit(self)
