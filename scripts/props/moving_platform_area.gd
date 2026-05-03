extends Area2D
class_name MovingPlatform

var last_global_position: Vector2
var movement_delta: Vector2 = Vector2.ZERO

func _ready() -> void:
	last_global_position = global_position

func _physics_process(_delta: float) -> void:
	movement_delta = global_position - last_global_position
	last_global_position = global_position
