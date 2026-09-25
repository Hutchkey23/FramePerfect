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
		"unlock_type": "world_medals",
		"world_id": "peaceful_plains",
		"unlock_value": 10,
		"locked_message": "Earn 10 medals in Peaceful Plains!"
	},
	{
		"id": "player_a",
		"display_name": "A",
		"texture": preload("res://assets/sprites/player/skins/a.png"),
		"description": "The letter a... but something seems suspicious.",
		"unlock_type": "world_medals",
		"world_id": "galactic_gateways",
		"unlock_value": 20,
		"locked_message": "Earn 20 medals in Galactic Gateways!"
	},
	{
		"id": "player_alien",
		"display_name": "Alien",
		"texture": preload("res://assets/sprites/player/skins/alien.png"),
		"description": "Bogos binted.",
		"unlock_type": "world_medals",
		"world_id": "galactic_gateways",
		"unlock_value": 10,
		"locked_message": "Earn 10 medals in Galactic Gateways!"
	},
	{
		"id": "player_blue",
		"display_name": "I'm Blue",
		"texture": preload("res://assets/sprites/player/skins/blue.png"),
		"description": "If I were green, I would die.",
		"unlock_type": "world_medals",
		"world_id": "frosted_frontier",
		"unlock_value": 15,
		"locked_message": "Earn 15 medals in Frosted Frontier!"
	},
	{
		"id": "player_blush",
		"display_name": "Blush",
		"texture": preload("res://assets/sprites/player/skins/blush.png"),
		"description": "Stop it, he's blushing!",
		"unlock_type": "world_medals",
		"world_id": "scorched_sands",
		"unlock_value": 20,
		"locked_message": "Earn 20 medals in Scorched Sands!"
	},
	{
		"id": "player_cactus",
		"display_name": "Cactus",
		"texture": preload("res://assets/sprites/player/skins/cactus.png"),
		"description": "He's got a point.",
		"unlock_type": "world_medals",
		"world_id": "scorched_sands",
		"unlock_value": 10,
		"locked_message": "Earn 10 medals in Scorched Sands!"
	},
	{
		"id": "player_familiar",
		"display_name": "Hutchkey",
		"texture": preload("res://assets/sprites/player/skins/familiar.png"),
		"description": "That looks like me! Not you, me!",
		"unlock_type": "marathon_medal",
		"marathon_id": "galactic_gateways",
		"locked_message": "Earn the medal in the Galactic Gateways Marathon!"
	},
	{
		"id": "player_hardest",
		"display_name": "Warrior",
		"texture": preload("res://assets/sprites/player/skins/hardest.png"),
		"description": "Been through the world's hardest challenges.",
		"unlock_type": "marathon_medal",
		"marathon_id": "all_worlds",
		"locked_message": "Earn the medal in the All Worlds Marathon!"
	},
	{
		"id": "player_lovely",
		"display_name": "Lovely",
		"texture": preload("res://assets/sprites/player/skins/lovely_day.png"),
		"description": "Is that what 'outside' looks like?",
		"unlock_type": "world_medals",
		"world_id": "peaceful_plains",
		"unlock_value": 20,
		"locked_message": "Earn 20 medals in Peaceful Plains!"
	},
	{
		"id": "player_polar",
		"display_name": "Polar",
		"texture": preload("res://assets/sprites/player/skins/polar.png"),
		"description": "If not friend, then why friend shaped?",
		"unlock_type": "world_medals",
		"world_id": "frosted_frontier",
		"unlock_value": 10,
		"locked_message": "Earn 10 medals in Frosted Frontier!"
	},
	{
		"id": "player_smile",
		"display_name": "Smile",
		"texture": preload("res://assets/sprites/player/skins/smile.png"),
		"description": "Why is he so happy?",
		"unlock_type": "world_medals",
		"world_id": "frosted_frontier",
		"unlock_value": 20,
		"locked_message": "Earn 20 medals in Frosted Frontier!"
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
		"unlock_type": "world_medals",
		"world_id": "peaceful_plains",
		"unlock_value": 5,
		"locked_message": "Earn 5 medals in Peaceful Plains!"
	},
	{
		"id": "goal_black",
		"display_name": "Black",
		"texture": preload("res://assets/sprites/goal/skins/black.png"),
		"description": "The classic mailbox but... black!",
		"unlock_type": "world_medals",
		"world_id": "galactic_gateways",
		"unlock_value": 5,
		"locked_message": "Earn 5 medals in Galactic Gateways!"
	},
	{
		"id": "goal_green",
		"display_name": "Green",
		"texture": preload("res://assets/sprites/goal/skins/green.png"),
		"description": "The classic mailbox but... green!",
		"unlock_type": "world_medals",
		"world_id": "peaceful_plains",
		"unlock_value": 15,
		"locked_message": "Earn 15 medals in Peaceful Plains!"
	},
	{
		"id": "goal_pink",
		"display_name": "Pink",
		"texture": preload("res://assets/sprites/goal/skins/pink.png"),
		"description": "The classic mailbox but... pink!",
		"unlock_type": "marathon_medal",
		"marathon_id": "peaceful_plains",
		"locked_message": "Earn the medal in the Peaceful Plains Marathon!"
	},
	{
		"id": "goal_purple",
		"display_name": "Purple",
		"texture": preload("res://assets/sprites/goal/skins/purple.png"),
		"description": "The classic mailbox but... purple!",
		"unlock_type": "world_medals",
		"world_id": "galactic_gateways",
		"unlock_value": 15,
		"locked_message": "Earn 15 medals in Galactic Gateways!"
	},
	{
		"id": "goal_red",
		"display_name": "Red",
		"texture": preload("res://assets/sprites/goal/skins/red.png"),
		"description": "The classic mailbox but... red!",
		"unlock_type": "world_medals",
		"world_id": "scorched_sands",
		"unlock_value": 15,
		"locked_message": "Earn 15 medals in Scorched Sands!"
	},
	{
		"id": "goal_white",
		"display_name": "White",
		"texture": preload("res://assets/sprites/goal/skins/white.png"),
		"description": "The classic mailbox but... white!",
		"unlock_type": "world_medals",
		"world_id": "frosted_frontier",
		"unlock_value": 5,
		"locked_message": "Earn 5 medals in Frosted Frontier!"
	},
	{
		"id": "goal_yellow",
		"display_name": "Yellow",
		"texture": preload("res://assets/sprites/goal/skins/yellow.png"),
		"description": "The classic mailbox but... yellow!",
		"unlock_type": "world_medals",
		"world_id": "scorched_sands",
		"unlock_value": 5,
		"locked_message": "Earn 5 medals in Scorched Sands!"
	},
	{
		"id": "goal_stripe",
		"display_name": "Striped",
		"texture": preload("res://assets/sprites/goal/skins/stripe.png"),
		"description": "Ready to race!",
		"unlock_type": "marathon_medal",
		"marathon_id": "scorched_sands",
		"locked_message": "Earn the medal in the Scorched Sands Marathon!"
	},
	{
		"id": "goal_bob",
		"display_name": "Bob",
		"texture": preload("res://assets/sprites/goal/skins/bob.png"),
		"description": "He looks hungry.",
		"unlock_type": "marathon_medal",
		"marathon_id": "frosted_frontier",
		"locked_message": "Earn the medal in the Frosted Frontier Marathon!"
	},
]


func get_skins(category: String) -> Array:
	if category == "player":
		return PLAYER_SKINS
	if category == "goal":
		return GOAL_SKINS
	return []


func is_skin_unlocked(skin_data: Dictionary) -> bool:
	match skin_data.get("unlock_type", ""):
		"default":
			return true

		"world_medals":
			var world_id: String = skin_data.get("world_id", "")
			var required_medals: int = skin_data.get("unlock_value", 0)

			return SaveManager.get_world_medal_count(world_id) >= required_medals

		"marathon_medal":
			var marathon_id: String = skin_data.get("marathon_id", "")

			return SaveManager.player_has_marathon_medal(marathon_id)

		"manual":
			return SaveManager.is_cosmetic_unlocked(
				skin_data.get("id", "")
			)

	return false

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
