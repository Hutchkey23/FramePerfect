extends CharacterBody2D
class_name Player

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision

# State
enum PlayerState {
	NORMAL,
	DASH,
	JUMP
}

var current_state: PlayerState = PlayerState.NORMAL

########### Movement ###########
const NORMAL_SPEED: float = 120.0
const ACCELERATION: float = 450.0
const BRAKING: float = 350.0

var move_input: Vector2 = Vector2.ZERO
var last_move_input: Vector2 = Vector2.RIGHT

# Dashing
const DASH_SPEED: float = 180.0
const DASH_DURATION: float = 0.20
const DASH_COOLDOWN: float = 0.5

var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# Jumping
const JUMP_HEIGHT: float = 72.0
const JUMP_DURATION: float = 0.35
const JUMP_COOLDOWN: float = 0.15

# Air movement during jump
const JUMP_MOVE_SPEED: float = 80.0
const JUMP_ACCELERATION: float = 250.0
const JUMP_BRAKING: float = 200.0

var jump_timer: float = 0.0
var jump_cooldown_timer: float = 0.0
var sprite_ground_y: float = 0.0

########## Animation ##########
const NORMAL_ROTATION_SPEED: float = 200.0
const DASH_ROTATION_SPEED: float = 1050.0
const JUMP_ROTATION_SPEED: float = 650.0
const ROTATION_SPEED_CHANGE_RATE: float = 600.0
const SHADOW_MIN_SCALE: float = 0.7

var current_rotation_speed: float = 0.0

# Dash Clouds
const DUST_CLOUD = preload("uid://db8k50wa1l8n")
const MIN_DUST_TRAVEL_DISTANCE : float = 4.0
const MAX_DUST_TRAVEL_DISTANCE : float = 20.0

# Jump Cloud
const JUMP_CLOUD = preload("uid://3d6xwo56h5a")

# Landing squash
var sprite_normal_scale: Vector2 = Vector2.ONE
var player_sprite_landing_tween: Tween
var shadow_sprite_landing_tween: Tween

func _ready() -> void:
	sprite_ground_y = player_sprite.position.y
	sprite_normal_scale = player_sprite.scale

func _physics_process(delta: float) -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if move_input != Vector2.ZERO:
		last_move_input = move_input

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if jump_cooldown_timer > 0.0:
		jump_cooldown_timer -= delta

	match current_state:
		PlayerState.NORMAL:
			handle_normal_movement(delta)
			try_start_dash()
			try_start_jump()

		PlayerState.DASH:
			handle_dash(delta)
			try_start_jump()

		PlayerState.JUMP:
			handle_jump(delta)

	move_and_slide()


func _process(delta: float) -> void:
	var target_rotation_speed: float = NORMAL_ROTATION_SPEED
	
	match current_state:
		PlayerState.NORMAL:
			target_rotation_speed = NORMAL_ROTATION_SPEED
			
			current_rotation_speed = move_toward(
				current_rotation_speed,
				target_rotation_speed,
				ROTATION_SPEED_CHANGE_RATE * delta
			)
		PlayerState.DASH:
			current_rotation_speed = DASH_ROTATION_SPEED
		PlayerState.JUMP:
			current_rotation_speed = JUMP_ROTATION_SPEED
	
	player_sprite.rotation_degrees += current_rotation_speed * delta
	shadow_sprite.rotation_degrees += current_rotation_speed * delta


func handle_normal_movement(delta: float) -> void:
	if move_input != Vector2.ZERO:
		var target_velocity := move_input * NORMAL_SPEED
		velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, BRAKING * delta)


func try_start_dash() -> void:
	if not Input.is_action_just_pressed("dash"):
		return

	# No air dash
	if current_state == PlayerState.JUMP:
		return

	if dash_cooldown_timer > 0.0:
		return

	if move_input == Vector2.ZERO:
		return

	current_state = PlayerState.DASH
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN

	dash_direction = last_move_input.normalized()
	velocity = dash_direction * DASH_SPEED
	
	spawn_dash_clouds(dash_direction)

func spawn_dash_clouds(direction: Vector2, number_of_clouds: int = 5) -> void:
	for cloud in number_of_clouds:
		var dust_cloud_instance = DUST_CLOUD.instantiate()
		
		get_parent().add_child(dust_cloud_instance)
		dust_cloud_instance.global_position = global_position
		
		var random_travel_distance: float = randf_range(MIN_DUST_TRAVEL_DISTANCE, MAX_DUST_TRAVEL_DISTANCE)
		
		var spread_angle := deg_to_rad(60.0) # total spread range
		var random_angle := randf_range(-spread_angle, spread_angle)

		var spread_direction := (-direction).rotated(random_angle)
		
		dust_cloud_instance.move_to(random_travel_distance, spread_direction)

func handle_dash(delta: float) -> void:
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED

	if dash_timer <= 0.0:
		current_state = PlayerState.NORMAL


func try_start_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return

	if jump_cooldown_timer > 0.0:
		return

	# Start jump from NORMAL or DASH
	current_state = PlayerState.JUMP
	jump_timer = JUMP_DURATION
	jump_cooldown_timer = JUMP_COOLDOWN
	
	var jump_cloud_instance = JUMP_CLOUD.instantiate()
	
	get_parent().add_child(jump_cloud_instance)
	jump_cloud_instance.global_position = global_position


func handle_jump(delta: float) -> void:
	jump_timer -= delta

	# Slight steering while airborne
	if move_input != Vector2.ZERO:
		var target_velocity := move_input * JUMP_MOVE_SPEED
		velocity = velocity.move_toward(target_velocity, JUMP_ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, JUMP_BRAKING * delta)

	# Visual jump arc
	var progress := 1.0 - (jump_timer / JUMP_DURATION)
	progress = clamp(progress, 0.0, 1.0)

	# Arc: 0 at start, peaks in middle, 0 at end
	var height := JUMP_HEIGHT * progress * (1.0 - progress)
	player_sprite.position.y = sprite_ground_y - height
	
	var height_ratio = (height * 4.0) / JUMP_HEIGHT
	var shadow_scale = lerp(1.0, SHADOW_MIN_SCALE, height_ratio)
	shadow_sprite.scale = Vector2(shadow_scale, shadow_scale * 0.9)
	shadow_sprite.modulate.a = lerp(1.0, 0.6, height_ratio)

	if jump_timer <= 0.0:
		player_sprite.position.y = sprite_ground_y
		shadow_sprite.scale = Vector2.ONE
		shadow_sprite.modulate.a = 1.0
		play_landing_squash()
		current_state = PlayerState.NORMAL

func play_landing_squash() -> void:
	if player_sprite_landing_tween:
		player_sprite_landing_tween.kill()
	
	if shadow_sprite_landing_tween:
		shadow_sprite_landing_tween.kill()
	
	player_sprite.scale = sprite_normal_scale
	var squash_scale := Vector2(sprite_normal_scale.x * 1.20, sprite_normal_scale.y * 0.90)
	
	player_sprite_landing_tween = create_tween()
	shadow_sprite_landing_tween = create_tween()
	
	player_sprite_landing_tween.tween_property(player_sprite, "scale", squash_scale, 0.04)
	shadow_sprite_landing_tween.tween_property(shadow_sprite, "scale", squash_scale, 0.04)
	
	player_sprite_landing_tween.chain().tween_property(player_sprite, "scale", sprite_normal_scale, 0.10).set_ease(Tween.EASE_OUT)
	shadow_sprite_landing_tween.chain().tween_property(shadow_sprite, "scale", sprite_normal_scale, 0.10).set_ease(Tween.EASE_OUT)
	
