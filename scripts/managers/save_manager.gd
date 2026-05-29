extends Node

const SAVE_PATH := "user://save_data.json"
const NO_TIME := 999999.0

const REMAPPABLE_ACTIONS: PackedStringArray = [
	"jump",
	"dash",
]

var save_data: Dictionary = get_default_save_data()


func _ready() -> void:
	load_game()


func get_default_level_data() -> Dictionary:
	return {
		"completed": false,
		"best_time": NO_TIME,
	}

func format_time(time: float) -> String:
	var minutes := int(time / 60.0)
	var seconds := fmod(time, 60.0)

	return "%d:%05.2f" % [minutes, seconds]

func get_or_create_level_data(level_id: String) -> Dictionary:
	if not save_data.has("levels"):
		save_data["levels"] = {}
	
	if not save_data["levels"].has(level_id):
		save_data["levels"][level_id] = get_default_level_data()
	
	return save_data["levels"][level_id]


func record_level_completion(level_id: String, clear_time: float) -> Dictionary:
	var level_data := get_or_create_level_data(level_id)
	var previous_best_time: float = level_data["best_time"]
	var medal_time: float = LevelDatabase.get_medal_time(level_id)
	var medal_already_achieved: bool = previous_best_time < medal_time

	level_data.completed = true

	var new_best := clear_time < previous_best_time
	if new_best:
		level_data["best_time"] = clear_time

	var best_time: float = level_data["best_time"]
	var earned_medal := best_time <= medal_time
	var earned_medal_this_run :=  clear_time < medal_time
	var first_completion := previous_best_time == NO_TIME

	save_game()

	return {
		"level_id": level_id,
		"clear_time": clear_time,
		"best_time": best_time,
		"previous_best_time": previous_best_time,
		"new_best": new_best,
		"missed_new_best_by": max(clear_time - best_time, 0.0),
		"first_completion": first_completion,
		"medal_time": medal_time,
		"medal_already_achieved": medal_already_achieved,
		"earned_medal": earned_medal,
		"earned_medal_this_run": earned_medal_this_run,
		"missed_medal_by": max(clear_time - medal_time, 0.0)
	}


func is_level_completed(level_id: String) -> bool:
	var level_data := get_or_create_level_data(level_id)
	return level_data["completed"]


func get_best_time(level_id: String) -> float:
	var level_data := get_or_create_level_data(level_id)
	return level_data["best_time"]


func has_best_time(level_id: String) -> bool:
	return get_best_time(level_id) < NO_TIME


func player_has_medal(level_id: String) -> bool:
	var best_time := get_best_time(level_id)
	if best_time >= NO_TIME:
		return false
		
	
	var medal_time := LevelDatabase.get_medal_time(level_id)
	return best_time <= medal_time

func get_best_marathon_time(marathon_id: String) -> float:
	var marathon_data := get_or_create_marathon_data(marathon_id)
	return marathon_data["best_time"]


func player_has_marathon_medal(marathon_id: String, medal_time: float) -> bool:
	var best_time := get_best_marathon_time(marathon_id)

	if best_time >= NO_TIME:
		return false

	return best_time <= medal_time

func reset_save_data() -> void:
	save_data = get_default_save_data()
	save_game()


func clear_save_data() -> void:
	save_data = get_default_save_data()
	
	if FileAccess.file_exists(SAVE_PATH):
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		if error != OK:
			push_error("Failed to delete save file: " + SAVE_PATH)
			save_game()
			return
	
	save_game()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: " + SAVE_PATH)
		return
	
	file.store_string(JSON.stringify(save_data, "\t"))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: " + SAVE_PATH)
		return
	
	var content := file.get_as_text()
	var json := JSON.new()
	var error := json.parse(content)
	
	if error != OK:
		push_error("Failed to parse save data from: " + SAVE_PATH)
		return
	
	var data = json.data
	if data is Dictionary:
		save_data = data
		
		if not save_data.has("levels"):
			save_data["levels"] = {}
		
		ensure_cosmetics_data()
		ensure_options_data()
		ensure_marathon_data()
		ensure_unlocks_data()
		load_input_map()
	else:
		push_error("Save data was not a Dictionary. Resetting save data.")
		save_data = {
			"levels": {}
		}

func get_default_save_data() -> Dictionary:
	return {
		"levels": {},
		"marathons": {},
		"unlocks": {
			"levels": {},
			"marathons": {},
			"cosmetics": {},
		},
		"cosmetics": {
			"selected_player_skin": "player_default",
			"selected_goal_skin": "goal_default",
		},
		"options": {
			"sfx_volume": 3,
			"music_volume": 3,
			"fullscreen": false,
			"screen_shake": true,
		}
	}

func ensure_marathon_data() -> void:
	if not save_data.has("marathons"):
		save_data["marathons"] = {}

func ensure_unlocks_data() -> void:
	if not save_data.has("unlocks"):
		save_data["unlocks"] = {}

	if not save_data["unlocks"].has("levels"):
		save_data["unlocks"]["levels"] = {}

	if not save_data["unlocks"].has("marathons"):
		save_data["unlocks"]["marathons"] = {}

	if not save_data["unlocks"].has("cosmetics"):
		save_data["unlocks"]["cosmetics"] = {}

func ensure_options_data() -> void:
	if not save_data.has("options"):
		save_data["options"] = {}
	
	if not save_data["options"].has("input_map"):
		save_data["options"]["input_map"] = ""
	
	if not save_data["options"].has("sfx_volume"):
		save_data["options"]["sfx_volume"] = 3
	
	if not save_data["options"].has("music_volume"):
		save_data["options"]["music_volume"] = 3
	
	if not save_data["options"].has("fullscreen"):
		save_data["options"]["fullscreen"] = false
	
	if not save_data["options"].has("screen_shake"):
		save_data["options"]["screen_shake"] = true

func save_input_map() -> void:
	ensure_options_data()

	var serialized_inputs := InputHelper.serialize_inputs_for_actions(REMAPPABLE_ACTIONS)
	save_data["options"]["input_map"] = serialized_inputs

	save_game()


func load_input_map() -> void:
	ensure_options_data()

	var serialized_inputs: String = save_data["options"].get("input_map", "")

	if serialized_inputs == "":
		return

	InputHelper.deserialize_inputs_for_actions(serialized_inputs)

func get_default_marathon_data() -> Dictionary:
	return {
		"completed": false,
		"best_time": NO_TIME,
		"best_deaths": 0,
	}

func get_or_create_marathon_data(marathon_id: String) -> Dictionary:
	ensure_marathon_data()

	if not save_data["marathons"].has(marathon_id):
		save_data["marathons"][marathon_id] = get_default_marathon_data()

	return save_data["marathons"][marathon_id]

func record_marathon_completion(
	marathon: MarathonData,
	clear_time: float,
	deaths: int,
	level_attempts: Dictionary
) -> Dictionary:
	var save_marathon_data := get_or_create_marathon_data(marathon.marathon_id)

	var previous_best_time: float = save_marathon_data["best_time"]
	var first_completion := previous_best_time == NO_TIME
	var new_best := clear_time < previous_best_time

	var medal_time := marathon.medal_time
	var had_medal_before := (
		previous_best_time != NO_TIME
		and previous_best_time <= medal_time
	)

	var earned_medal := clear_time <= medal_time
	var first_medal := earned_medal and not had_medal_before

	save_marathon_data["completed"] = true

	if new_best:
		save_marathon_data["best_time"] = clear_time
		save_marathon_data["best_deaths"] = deaths
		save_marathon_data["best_level_attempts"] = level_attempts.duplicate(true)
	
	var missed_medal_by := 0.0
	if not earned_medal:
		missed_medal_by = clear_time - medal_time

	var missed_new_best_by := 0.0
	if not new_best and previous_best_time != NO_TIME:
		missed_new_best_by = clear_time - previous_best_time
	
	save_game()

	return {
		"marathon_id": marathon.marathon_id,
		"display_name": marathon.display_name,
		"clear_time": clear_time,
		"previous_best_time": previous_best_time,
		"best_time": save_marathon_data["best_time"],
		"new_best": new_best,
		"first_completion": first_completion,
		"deaths": deaths,
		"level_attempts": level_attempts,

		"medal_time": medal_time,
		"earned_medal": earned_medal,
		"first_medal": first_medal,

		"missed_medal_by": missed_medal_by,
		"missed_new_best_by": missed_new_best_by,
	}

func get_option(option_name: String, fallback = null):
	ensure_options_data()
	return save_data["options"].get(option_name, fallback)


func set_option(option_name: String, value) -> void:
	ensure_options_data()
	save_data["options"][option_name] = value
	save_game()


func get_selected_skin(category: String) -> String:
	ensure_cosmetics_data()
	
	if category == "player":
		return save_data["cosmetics"]["selected_player_skin"]
	if category == "goal":
		return save_data["cosmetics"]["selected_goal_skin"]
	
	return ""


func set_selected_skin(category: String, skin_id: String) -> void:
	ensure_cosmetics_data()
	
	if category == "player":
		save_data["cosmetics"]["selected_player_skin"] = skin_id
	elif category == "goal":
		save_data["cosmetics"]["selected_goal_skin"] = skin_id
	
	save_game()


func ensure_cosmetics_data() -> void:
	if not save_data.has("cosmetics"):
		save_data["cosmetics"] = {}
	
	if not save_data["cosmetics"].has("selected_player_skin"):
		save_data["cosmetics"]["selected_player_skin"] = "player_default"
	
	if not save_data["cosmetics"].has("selected_goal_skin"):
		save_data["cosmetics"]["selected_goal_skin"] = "goal_default"

func is_level_unlocked(level_id: String) -> bool:
	ensure_unlocks_data()
	return save_data["unlocks"]["levels"].get(level_id, false)


func unlock_level(level_id: String) -> bool:
	ensure_unlocks_data()

	if is_level_unlocked(level_id):
		return false

	save_data["unlocks"]["levels"][level_id] = true
	save_game()
	return true
	

func is_marathon_unlocked(marathon_id: String) -> bool:
	ensure_unlocks_data()
	return save_data["unlocks"]["marathons"].get(marathon_id, false)


func unlock_marathon(marathon_id: String) -> bool:
	ensure_unlocks_data()

	if is_marathon_unlocked(marathon_id):
		return false

	save_data["unlocks"]["marathons"][marathon_id] = true
	save_game()
	return true

func is_cosmetic_unlocked(cosmetic_id: String) -> bool:
	ensure_unlocks_data()
	return save_data["unlocks"]["cosmetics"].get(cosmetic_id, false)


func unlock_cosmetic(cosmetic_id: String) -> bool:
	ensure_unlocks_data()

	if is_cosmetic_unlocked(cosmetic_id):
		return false

	save_data["unlocks"]["cosmetics"][cosmetic_id] = true
	save_game()
	return true
