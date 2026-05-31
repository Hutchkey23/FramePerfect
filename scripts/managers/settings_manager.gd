extends Node

const SFX_VOLUME_DB_LEVELS: Array[float] = [
	-80.0,
	-12.0,
	-6.0,
	0.0,
	4.0,
	8.0
]

const BGM_VOLUME_DB_LEVELS: Array[float] = [
	-80.0,
	-16.0,
	-12.0,
	-6.0,
	0.0,
	4.0
]

func _ready() -> void:
	apply_all_settings()
	RenderingServer.set_default_clear_color(Color("#000000"))


func apply_all_settings() -> void:
	apply_audio_settings()
	apply_display_settings()


func apply_audio_settings() -> void:
	set_bus_volume("SFX", SaveManager.get_option("sfx_volume", 3))
	set_bus_volume("Music", SaveManager.get_option("music_volume", 3))


func apply_display_settings() -> void:
	var fullscreen: bool = SaveManager.get_option("fullscreen", true)

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func set_bus_volume(bus_name: String, value: int) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus not found: " + bus_name)
		return

	value = clampi(value, 0, 5)

	var volume_array: Array[float]
	match bus_name:
		"SFX":
			volume_array = SFX_VOLUME_DB_LEVELS
		"Music":
			volume_array = BGM_VOLUME_DB_LEVELS
		_:
			push_warning("No volume array for bus: " + bus_name)
			return

	AudioServer.set_bus_volume_db(bus_index, volume_array[value])
	AudioServer.set_bus_mute(bus_index, value == 0)
