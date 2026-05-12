extends Node

################################ MUSIC ################################
const BGM_VOLUME : float = -8.0
const SEND_IT = preload("uid://dm4lfm5ey1aya")

###############################################################################

#const WORLD_BGM_MIN_TIME := 120.0
#const WORLD_BGM_MAX_TIME := 180.0
const WORLD_BGM_MIN_TIME := 20.0
const WORLD_BGM_MAX_TIME := 30.0
const WORLD_BGM_CROSSFADE_TIME := 8.0

var world_playlist: Array[AudioStream] = []
var world_song_index: int = -1
var world_bgm_active: bool = false

var song_change_timer: SceneTreeTimer

@onready var audio_player := AudioStreamPlayer.new()
var fade_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	audio_player.bus = "Music"
	add_child(audio_player)

	if AudioServer.get_bus_index("Music") == -1:
		push_error("Music bus not found! Make sure it exists in Audio Bus Layout.")

func play_world_playlist(
	songs: Array[AudioStream],
	start_random: bool = true,
	volume_db: float = BGM_VOLUME
) -> void:
	if songs.is_empty():
		fade_out(1.0)
		world_bgm_active = false
		world_playlist.clear()
		world_song_index = -1
		return

	world_playlist = songs.duplicate()
	world_bgm_active = true

	if start_random:
		world_song_index = randi_range(0, world_playlist.size() - 1)
	else:
		world_song_index = 0

	play(world_playlist[world_song_index], volume_db, 1.5)
	_schedule_next_world_song(volume_db)


func stop_world_playlist(fade_duration: float = 1.0) -> void:
	world_bgm_active = false
	world_playlist.clear()
	world_song_index = -1
	fade_out(fade_duration)


func _schedule_next_world_song(volume_db: float = BGM_VOLUME) -> void:
	if not world_bgm_active:
		return

	var wait_time := randf_range(WORLD_BGM_MIN_TIME, WORLD_BGM_MAX_TIME)

	await get_tree().create_timer(wait_time).timeout

	if not world_bgm_active:
		return

	_play_next_world_song(volume_db)


func _play_next_world_song(volume_db: float = BGM_VOLUME) -> void:
	if world_playlist.is_empty():
		return

	world_song_index += 1

	if world_song_index >= world_playlist.size():
		world_song_index = 0

	var next_song := world_playlist[world_song_index]

	cross_fade(next_song, WORLD_BGM_CROSSFADE_TIME, volume_db)

	_schedule_next_world_song(volume_db)

# ----------------------------------------------------
# Basic Play (no fade)
# ----------------------------------------------------
func play(
	stream: AudioStream,
	volume_db: float = BGM_VOLUME,
	fade_duration: float = 0.0
) -> void:
	if audio_player.playing and audio_player.stream == stream:
		return

	if not audio_player.playing:
		_stop_fade()
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
		return

	if fade_duration == 0.0:
		_stop_fade()
		audio_player.stop()
		audio_player.stream = stream
		audio_player.volume_db = volume_db
		audio_player.play()
	else:
		cross_fade(stream, fade_duration, volume_db)

# ----------------------------------------------------
# Cross Fade
# ----------------------------------------------------
func cross_fade(
	new_stream: AudioStream,
	duration: float,
	target_volume_db: float
) -> void:
	_stop_fade()

	var old_player := audio_player
	var new_player := AudioStreamPlayer.new()
	
	new_player.bus = old_player.bus
	new_player.stream = new_stream
	new_player.volume_db = -20.0 # Start silent for fade-in
	add_child(new_player)
	new_player.play()

	# Fade out old
	create_tween().tween_property(
		old_player,
		"volume_db",
		-80.0,
		duration
	).set_trans(Tween.TRANS_LINEAR)

	# Fade in new
	var in_tween := create_tween()
	in_tween.tween_property(
		new_player,
		"volume_db",
		target_volume_db,
		duration
	).set_trans(Tween.TRANS_LINEAR)

	await in_tween.finished

	old_player.stop()
	old_player.queue_free()
	audio_player = new_player

# ----------------------------------------------------
# Cross Fade Random
# ----------------------------------------------------
func cross_fade_random(
	new_stream: AudioStream,
	duration: float = 2.0, # Increased default for smoother overlap
	target_volume_db: float = 0.0,
	min_offset_seconds: float = 0.0
) -> void:
	if audio_player.playing and audio_player.stream == new_stream:
		return
	
	_stop_fade()

	var old_player := audio_player
	var new_player := AudioStreamPlayer.new()
	
	new_player.bus = old_player.bus
	new_player.stream = new_stream
	new_player.volume_db = -80.0
	add_child(new_player)
	
	# Calculate and seek random position
	var length := new_stream.get_length()
	if length > 0.0:
		var max_offset = max(length - min_offset_seconds, 0.0)
		var start_time = randf_range(0.0, max_offset)
		new_player.play(start_time)
	else:
		new_player.play()

	# Use ONE tween to handle both players simultaneously
	var combined_tween = create_tween().set_parallel(true)
	
	# Fade out old - Use TRANS_SINE for a more natural power curve
	combined_tween.tween_property(
		old_player,
		"volume_db",
		-80.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Fade in new - Overlapping exactly with the fade out
	combined_tween.tween_property(
		new_player,
		"volume_db",
		target_volume_db,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Once the combined tween is finished, clean up
	combined_tween.set_parallel(false) # Chains the next callback
	combined_tween.tween_callback(func():
		if is_instance_valid(old_player):
			old_player.stop()
			old_player.queue_free()
	)
	
	# Update the reference immediately so other calls don't interfere
	audio_player = new_player

# ----------------------------------------------------
# Fade In Random
# ----------------------------------------------------
func play_fade_in_random(
	stream: AudioStream,
	duration: float = 1.0,
	target_volume_db: float = 0.0,
	min_offset_seconds: float = 0.0
) -> void:
	_stop_fade()
	
	if audio_player.playing and audio_player.stream == stream:
		return
	
	audio_player.stop()
	audio_player.stream = stream
	audio_player.volume_db = -80.0

	var length := stream.get_length()
	var start_time := 0.0
	if length > 0.0:
		var max_offset = max(length - min_offset_seconds, 0.0)
		start_time = randf_range(0.0, max_offset)
	
	audio_player.play(start_time)

	fade_tween = create_tween()
	fade_tween.tween_property(
		audio_player,
		"volume_db",
		target_volume_db,
		duration
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

# ----------------------------------------------------
# Helpers
# ----------------------------------------------------
func _stop_fade() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		fade_tween = null
