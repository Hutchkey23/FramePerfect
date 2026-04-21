extends Control

@onready var player_icon: TextureRect = $PlayerIcon

const PLAYER_ROTATION_SPEED : float = 250.0

func _ready() -> void:
	player_icon.pivot_offset = player_icon.size / 2

func _process(delta: float) -> void:
	player_icon.rotation_degrees += PLAYER_ROTATION_SPEED * delta
