extends Node

const SAVE_PATH := "user://save_data.json"
const NO_TIME := 999999.0

var save_data: Dictionary = {
	"levels": {}
}


func _ready() -> void:
	load_game()


func get_default_level_data() -> Dictionary:
	return {
		"completed": false,
		"best_time": NO_TIME,
	}


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
	var earned_medal_this_run :=  not medal_already_achieved
	var first_completion := previous_best_time == NO_TIME

	save_game()

	return {
		"level_id": level_id,
		"clear_time": clear_time,
		"best_time": best_time,
		"previous_best_time": previous_best_time,
		"new_best": new_best,
		"first_completion": first_completion,
		"medal_time": medal_time,
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


func reset_save_data() -> void:
	save_data = {
		"levels": {}
	}
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
	else:
		push_error("Save data was not a Dictionary. Resetting save data.")
		save_data = {
			"levels": {}
		}
