extends Area2D
class_name JumpPad

@onready var jump_pad_sprite: Sprite2D = $JumpPadSprite
@onready var sfx_pool: Node2D = $SFXPool

@export var jump_height: float = 120.0
@export var jump_duration: float = 0.48
@export var min_forward_speed: float = 0.0
@export var cooldown_time: float = 0.12

var can_launch: bool = true
var launch_tween: Tween
var checking_for_player_landing: bool = false

var player_reference: Player = null

const LAUNCH_SFX: AudioStream = preload("uid://dgq3ojejv0hog")
const LAUNCH_VOLUME: float = -6.0
const LAUNCH_PITCH_RANGE: Vector2 = Vector2(0.9, 1.15)

func _on_body_entered(body: Node2D) -> void:
	if not can_launch:
		return

	if not body.is_in_group("player"):
		return

	if not body is Player:
		return
	
	player_reference = body
	checking_for_player_landing = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_reference = null
		checking_for_player_landing = false

func _process(_delta: float) -> void:
	if not checking_for_player_landing:
		return
	
	if player_reference:
		if abs(player_reference.player_sprite.position.y - player_reference.sprite_ground_y) < 0.2 and can_launch:
			checking_for_player_landing = false
			launch_player(player_reference)
	else:
		checking_for_player_landing = false

func launch_player(player: Player) -> void:
	can_launch = false

	player.start_jump_pad_jump(
		jump_height,
		jump_duration,
		min_forward_speed
	)

	play_launch_animation()
	play_sfx(LAUNCH_SFX, LAUNCH_VOLUME, LAUNCH_PITCH_RANGE)

	await get_tree().create_timer(cooldown_time).timeout
	can_launch = true
	
	if player_reference:
		checking_for_player_landing = true


func play_launch_animation() -> void:
	if launch_tween:
		launch_tween.kill()

	jump_pad_sprite.scale = Vector2.ONE

	launch_tween = create_tween()
	launch_tween.tween_property(
		jump_pad_sprite,
		"scale",
		Vector2(1.18, 0.82),
		0.05
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	launch_tween.chain().tween_property(
		jump_pad_sprite,
		"scale",
		Vector2(0.92, 1.18),
		0.08
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	launch_tween.chain().tween_property(
		jump_pad_sprite,
		"scale",
		Vector2.ONE,
		0.10
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func play_sfx(
	sfx: AudioStream,
	volume_db: float = 0.0,
	pitch_range: Vector2 = Vector2(0.95, 1.05)
) -> void:
	for audio_player: AudioStreamPlayer2D in sfx_pool.get_children():
		if not audio_player.playing:
			audio_player.volume_db = volume_db
			audio_player.stream = sfx
			audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
			audio_player.play()
			return
