extends StaticBody2D
class_name ToggleBlock

const ON_SPRITE: Texture2D = preload("uid://3031j7vqm26d")
const OFF_SPRITE: Texture2D = preload("uid://b5bxo1utfwkuu")

@export var start_toggled: bool = true

var player_reference: Player
var toggled: bool
var pop_tween: Tween

@onready var toggle_block_sprite: Sprite2D = $ToggleBlockSprite
@onready var toggle_block_collision: CollisionShape2D = $ToggleBlockCollision


func _ready() -> void:
	toggled = start_toggled
	apply_toggle_state(false)


func toggle() -> void:
	toggled = !toggled
	apply_toggle_state(true)


func apply_toggle_state(animate: bool = true) -> void:
	if toggled:
		toggle_block_sprite.texture = ON_SPRITE
		toggle_block_collision.disabled = false
		toggle_block_sprite.modulate.a = 1.0
	else:
		toggle_block_sprite.texture = OFF_SPRITE
		toggle_block_collision.disabled = true
		toggle_block_sprite.modulate.a = 0.55

	if animate:
		play_pop_animation()


func play_pop_animation() -> void:
	if pop_tween:
		pop_tween.kill()

	toggle_block_sprite.scale = Vector2.ONE

	pop_tween = create_tween()
	pop_tween.tween_property(
		toggle_block_sprite,
		"scale",
		Vector2(1.2, 1.2),
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		toggle_block_sprite,
		"scale",
		Vector2.ONE,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
