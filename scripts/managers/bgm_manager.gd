extends Node

################################ MUSIC ################################

const BGM_VOLUME: float = -8.0
const SEND_IT = preload("uid://dm4lfm5ey1aya")

const WORLD_BGM_FADE_OUT_TIME := 5.0
const WORLD_BGM_SILENCE_TIME := 1.0

###############################################################################

var world_playlist: Array[MusicData] = []
var world_song_index: int = -1
var world_bgm_active: bool = false

var playlist_version: int = 0

var audio_player : AudioStreamPlayer
var fade_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Music"
	add_child(audio_player)

	if AudioServer.get_bus_index("Music") == -1:
		push_error("Music bus not found! Make sure it exists in Audio Bus Layout.")


func play_world_playlist(
	songs: Array[MusicData],
	start_random: bool = true
) -> void:
	# Cancels any previous playlist loop.
	playlist_version += 1
	var my_version := playlist_version

	if songs.is_empty():
		stop_world_playlist()
		return

	world_playlist = songs.duplicate()
	world_bgm_active = true

	if start_random:
		world_song_index = randi_range(0, world_playlist.size() - 1)
	else:
		world_song_index = 0

	_play_current_world_song(my_version)


func stop_world_playlist(fade_duration: float = 1.0) -> void:
	playlist_version += 1

	world_bgm_active = false
	world_playlist.clear()
	world_song_index = -1

	fade_out(fade_duration)


func _play_current_world_song(version: int = playlist_version) -> void:
	if not world_bgm_active or version != playlist_version:
		return

	if world_playlist.is_empty():
		return

	var music_data := world_playlist[world_song_index]

	if music_data == null:
		_play_next_world_song(version)
		return

	if music_data.bgm_file == null:
		_play_next_world_song(version)
		return
	
	play(music_data.bgm_file, music_data.volume_db, 0.0)

	var play_time := get_random_play_length(music_data)
	_schedule_next_world_song(play_time, version)


func _schedule_next_world_song(
	play_time: float,
	version: int = playlist_version
) -> void:
	if not world_bgm_active or version != playlist_version:
		return

	await get_tree().create_timer(play_time).timeout

	if not world_bgm_active or version != playlist_version:
		return

	await fade_out(WORLD_BGM_FADE_OUT_TIME)

	if not world_bgm_active or version != playlist_version:
		return

	await get_tree().create_timer(WORLD_BGM_SILENCE_TIME).timeout

	if not world_bgm_active or version != playlist_version:
		return

	_play_next_world_song(version)


func _play_next_world_song(version: int = playlist_version) -> void:
	if not world_bgm_active or version != playlist_version:
		return

	if world_playlist.is_empty():
		return

	world_song_index += 1

	if world_song_index >= world_playlist.size():
		world_song_index = 0

	_play_current_world_song(version)


func get_random_play_length(music_data: MusicData) -> float:
	var min_length := music_data.play_length_min
	var max_length := music_data.play_length_max

	if max_length < min_length:
		max_length = min_length

	return float(randi_range(min_length, max_length))


# ----------------------------------------------------
# Basic Play
# ----------------------------------------------------
func play(
	stream: AudioStream,
	volume_db: float = BGM_VOLUME,
	fade_duration: float = 0.0
) -> void:
	if audio_player.playing and audio_player.stream == stream:
		return

	_stop_fade()

	audio_player.stop()
	audio_player.stream = stream
	audio_player.volume_db = volume_db if fade_duration == 0.0 else -80.0
	audio_player.play()

	if fade_duration > 0.0:
		fade_tween = create_tween()
		fade_tween.tween_property(
			audio_player,
			"volume_db",
			volume_db,
			fade_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ----------------------------------------------------
# Fade Out
# ----------------------------------------------------
func fade_out(duration: float = 1.0) -> void:
	if not audio_player.playing:
		return

	_stop_fade()

	fade_tween = create_tween()
	fade_tween.tween_property(
		audio_player,
		"volume_db",
		-80.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await fade_tween.finished

	if is_instance_valid(audio_player):
		audio_player.stop()
		audio_player.volume_db = BGM_VOLUME


# ----------------------------------------------------
# Helpers
# ----------------------------------------------------
func _stop_fade() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		fade_tween = null
