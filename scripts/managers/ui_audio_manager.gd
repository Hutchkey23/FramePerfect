extends Node

const UI_VOLUME: float = -8.0
const UI_PITCH_RANGE: Vector2 = Vector2(0.85, 0.90)

const UI_ERROR = preload("uid://b0pg8pnoinimx")
const UI_POP = preload("uid://cpteyuhy2durf")
const UI_SLIDE = preload("uid://dk3ggub5fmymc")

const POSTCARD_FLIP = preload("uid://dcsn0taodew5q")
const POSTCARD_FLIP_TO_FRONT = preload("uid://dxr7tthgq7ptd")


const POOL_SIZE := 20
var ui_sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		ui_sfx_players.append(player)

func play_ui_error_sfx() -> void:
	play_ui_sfx(UI_ERROR)

func play_ui_nav_sfx() -> void:
	play_ui_sfx(UI_POP, UI_VOLUME - 6, Vector2(1.4, 1.45))

func play_ui_confirm_sfx() -> void:
	play_ui_sfx(UI_POP)

func play_ui_cancel_sfx() -> void:
	play_ui_sfx(UI_POP, UI_VOLUME, Vector2(0.5, 0.55))

func play_ui_pip_sfx() -> void:
	play_ui_sfx(UI_POP, UI_VOLUME - 6.0, Vector2(1.0, 1.1))

func play_ui_slide_sfx() -> void:
	play_ui_sfx(UI_SLIDE)

func play_postcard_flip_to_back_sfx() -> void:
	play_ui_sfx(POSTCARD_FLIP, UI_VOLUME + 3.0)
	
func play_postcard_flip_to_front_sfx() -> void:
	play_ui_sfx(POSTCARD_FLIP_TO_FRONT, UI_VOLUME + 1.0)

func play_ui_sfx(sfx: AudioStream, volume_db := UI_VOLUME, pitch_range: Vector2 = UI_PITCH_RANGE) -> void:
	for player in ui_sfx_players:
		if not player.playing:
			player.stream = sfx
			player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
			player.volume_db = volume_db
			player.play()
			return
