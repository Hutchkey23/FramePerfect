extends Area2D
class_name TogglePlatform

const ON_SPRITE: Texture2D = preload("uid://qk2cmdyouqgj")
const OFF_SPRITE: Texture2D = preload("uid://b6on6q35abxec")

@export var start_toggled: bool = true

var player_reference: Player
var toggled: bool
var pop_tween: Tween

@onready var toggle_platform_sprite: Sprite2D = $TogglePlatformSprite
@onready var toggle_platform_collision: CollisionShape2D = $TogglePlatformCollision


func _ready() -> void:
	toggled = start_toggled
	apply_toggle_state(false)

	player_reference = get_tree().get_first_node_in_group("player")
	
	if player_reference:
		player_reference.player_jumped.connect(toggle)


func toggle() -> void:
	toggled = !toggled
	apply_toggle_state(true)


func apply_toggle_state(animate: bool = true) -> void:
	if toggled:
		toggle_platform_sprite.texture = ON_SPRITE
		toggle_platform_collision.disabled = false
		toggle_platform_sprite.modulate.a = 1.0
	else:
		toggle_platform_sprite.texture = OFF_SPRITE
		toggle_platform_collision.disabled = true
		toggle_platform_sprite.modulate.a = 0.55

	if animate:
		play_pop_animation()


func play_pop_animation() -> void:
	if pop_tween:
		pop_tween.kill()

	toggle_platform_sprite.scale = Vector2.ONE

	pop_tween = create_tween()
	pop_tween.tween_property(
		toggle_platform_sprite,
		"scale",
		Vector2(1.2, 1.2),
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		toggle_platform_sprite,
		"scale",
		Vector2.ONE,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
