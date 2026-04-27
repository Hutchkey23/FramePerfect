extends Node

const DEFAULT_PLAYER_TEXTURE = preload("res://assets/sprites/player/player.png") 
const DEFAULT_GOAL_TEXTURE = preload("res://assets/sprites/goal/goal.png")

const PLAYER_SKINS := [
	{
		"id": "player_default",
		"display_name": "Default",
		"texture": DEFAULT_PLAYER_TEXTURE,
		"description": "The classic delivery square.",
		"unlock_type": "default",
	},
	{
		"id": "player_checker",
		"display_name": "Checker",
		"texture": preload("res://assets/sprites/player/skins/checkerboard.png"),
		"description": "Playing Send It! while everyone else plays checkers.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_a",
		"display_name": "A",
		"texture": preload("res://assets/sprites/player/skins/a.png"),
		"description": "The letter a... but something seems suspicious.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_alien",
		"display_name": "Alien",
		"texture": preload("res://assets/sprites/player/skins/alien.png"),
		"description": "Bogos binted.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_blue",
		"display_name": "I'm Blue",
		"texture": preload("res://assets/sprites/player/skins/blue.png"),
		"description": "If I were green, I would die.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_blush",
		"display_name": "Blush",
		"texture": preload("res://assets/sprites/player/skins/blush.png"),
		"description": "Stop it, he's blushing!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_cactus",
		"display_name": "Cactus",
		"texture": preload("res://assets/sprites/player/skins/cactus.png"),
		"description": "He's got a point.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_familiar",
		"display_name": "Hutchkey",
		"texture": preload("res://assets/sprites/player/skins/familiar.png"),
		"description": "That looks like me! Not you, me!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_hardest",
		"display_name": "Warrior",
		"texture": preload("res://assets/sprites/player/skins/hardest.png"),
		"description": "Been through the world's hardest challenges.",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_lovely",
		"display_name": "Lovely",
		"texture": preload("res://assets/sprites/player/skins/lovely_day.png"),
		"description": "Is that what 'outside' looks like?",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_polar",
		"display_name": "Polar",
		"texture": preload("res://assets/sprites/player/skins/polar.png"),
		"description": "If not friend, then why friend shaped?",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "player_smile",
		"display_name": "Smile",
		"texture": preload("res://assets/sprites/player/skins/smile.png"),
		"description": "Why is he so happy?",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
]

const GOAL_SKINS := [
	{
		"id": "goal_default",
		"display_name": "Default",
		"texture": DEFAULT_GOAL_TEXTURE,
		"description": "The classic mailbox.",
		"unlock_type": "default",
	},
	{
		"id": "goal_brown",
		"display_name": "Brown",
		"texture": preload("res://assets/sprites/goal/skins/brown.png"),
		"description": "The classic mailbox but... brown!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_black",
		"display_name": "Black",
		"texture": preload("res://assets/sprites/goal/skins/black.png"),
		"description": "The classic mailbox but... black!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_green",
		"display_name": "Green",
		"texture": preload("res://assets/sprites/goal/skins/green.png"),
		"description": "The classic mailbox but... green!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_pink",
		"display_name": "Pink",
		"texture": preload("res://assets/sprites/goal/skins/pink.png"),
		"description": "The classic mailbox but... pink!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_purple",
		"display_name": "Purple",
		"texture": preload("res://assets/sprites/goal/skins/purple.png"),
		"description": "The classic mailbox but... purple!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_red",
		"display_name": "Red",
		"texture": preload("res://assets/sprites/goal/skins/red.png"),
		"description": "The classic mailbox but... red!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_white",
		"display_name": "White",
		"texture": preload("res://assets/sprites/goal/skins/white.png"),
		"description": "The classic mailbox but... white!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_yellow",
		"display_name": "Yellow",
		"texture": preload("res://assets/sprites/goal/skins/yellow.png"),
		"description": "The classic mailbox but... yellow!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_stripe",
		"display_name": "Striped",
		"texture": preload("res://assets/sprites/goal/skins/stripe.png"),
		"description": "Ready to race!",
		"unlock_type": "levels_completed",
		"unlock_value": 10,
		"locked_message": "Unlock by completing 10 levels!"
	},
	{
		"id": "goal_bob",
		"display_name": "Bob",
		"texture": preload("res://assets/sprites/goal/skins/bob.png"),
		"description": "He looks hungry.",
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

func retrieve_skin_texture(category: String, skin_id: String) -> Texture:
	match category:
		"player":
			for skin in PLAYER_SKINS:
				if skin.id == skin_id:
					return skin.texture
			return DEFAULT_PLAYER_TEXTURE
		"goal":
			for skin in GOAL_SKINS:
				if skin.id == skin_id:
					return skin.texture
			return DEFAULT_GOAL_TEXTURE
	return null
