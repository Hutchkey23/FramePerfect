extends Node

const PLAYER_SKINS := [
	{
		"id": "player_default",
		"display_name": "Default",
		"texture": preload("res://assets/sprites/player/player.png"),
		"description": "The classic delivery square.",
		"unlock_type": "default",
	},
	{
		"id": "player_checker",
		"display_name": "Checker",
		"texture": preload("res://assets/sprites/player/skins/checkerboard.png"),
		"description": "For players who like a little style.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
]

const GOAL_SKINS := [
	{
		"id": "goal_default",
		"display_name": "Default",
		"texture": preload("res://assets/sprites/goal/goal.png"),
		"description": "The classic mailbox.",
		"unlock_type": "default",
	},
	{
		"id": "goal_checker",
		"display_name": "Brown",
		"texture": preload("res://assets/sprites/goal/skins/brown.png"),
		"description": "A mailbox with extra flair.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
]


func get_skins(category: String) -> Array:
	if category == "player":
		return PLAYER_SKINS
	if category == "goal":
		return GOAL_SKINS
	return []


func is_skin_unlocked(skin_data: Dictionary) -> bool:
	# Testing mode: everything unlocked for now.
	return true

	# Later:
	# match skin_data.get("unlock_type", ""):
	# 	"default":
	# 		return true
	# 	"levels_completed":
	# 		return SaveManager.get_completed_level_count() >= skin_data.get("unlock_value", 0)
	# 	"medals":
	# 		return SaveManager.get_medal_count() >= skin_data.get("unlock_value", 0)
	# return false
