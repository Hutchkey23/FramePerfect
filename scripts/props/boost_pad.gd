extends Area2D
class_name BoostPad

@export var boost_speed: float = 340.0
@export var boost_duration: float = 0.18

@onready var launch_direction_marker: Marker2D = $LaunchDirection
@onready var boost_pad_sprite: Sprite2D = $BoostPadSprite
@onready var sfx_pool: Node2D = $SFXPool

var player_reference: Player = null
var trying_to_start_boost: bool = false

var base_visual_position: Vector2
var base_visual_scale: Vector2
var boost_tween: Tween

######### AUDIO #########
const BOOST_SOUND_EFFECT: AudioStream = preload("uid://cl7ft1alo4o04")
const BOOST_VOLUME: float = -4.0
const BOOST_PITCH_RANGE: Vector2 = Vector2(0.9, 1.1)
#########################

func _ready() -> void:
	base_visual_position = boost_pad_sprite.position
	base_visual_scale = boost_pad_sprite.scale


func _process(_delta: float) -> void:
	if not trying_to_start_boost:
		return
	
	if player_reference:
		if player_reference.player_sprite.position.y == player_reference.sprite_ground_y:
			var direction := get_boost_direction()
			player_reference.velocity = Vector2.ZERO
			player_reference.start_boost(direction, boost_speed, boost_duration)
			play_boost_animation(direction)
			trying_to_start_boost = false

func get_boost_direction() -> Vector2:
	return (launch_direction_marker.global_position - global_position).normalized()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_reference = body
		trying_to_start_boost = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		trying_to_start_boost = false

func play_boost_animation(direction: Vector2) -> void:
	if boost_tween:
		boost_tween.kill()
	
	play_sfx(BOOST_SOUND_EFFECT, BOOST_VOLUME, BOOST_PITCH_RANGE)
	
	boost_pad_sprite.position = base_visual_position
	boost_pad_sprite.scale = base_visual_scale

	var local_direction := direction.rotated(-global_rotation).normalized()
	var kick_distance := 7.0

	boost_tween = create_tween()
	boost_tween.set_parallel(true)

	# Jolt forward hard.
	boost_tween.tween_property(
		boost_pad_sprite,
		"position",
		base_visual_position + local_direction * kick_distance,
		0.045
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Squash/stretch in the direction of launch.
	boost_tween.tween_property(
		boost_pad_sprite,
		"scale",
		base_visual_scale * Vector2(1.18, 0.82),
		0.045
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Return with bounce.
	boost_tween.chain()

	boost_tween.tween_property(
		boost_pad_sprite,
		"position",
		base_visual_position - local_direction * 2.0,
		0.08
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	boost_tween.tween_property(
		boost_pad_sprite,
		"scale",
		base_visual_scale * Vector2(0.94, 1.08),
		0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	boost_tween.chain()

	boost_tween.tween_property(
		boost_pad_sprite,
		"position",
		base_visual_position,
		0.08
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	boost_tween.tween_property(
		boost_pad_sprite,
		"scale",
		base_visual_scale,
		0.08
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

####### AUDIO HANDLING ########
func play_sfx(sfx: AudioStream, volume_db: float = 0.0, pitch_range: Vector2 = Vector2(0.95, 1.05)):
	for audio_player: AudioStreamPlayer2D in sfx_pool.get_children():
		if not audio_player.playing:
			audio_player.volume_db = volume_db
			audio_player.stream = sfx
			audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
			audio_player.play()
			return
###############################
