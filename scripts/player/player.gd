extends CharacterBody2D
class_name Player

signal player_jumped
signal died
signal goal_reached

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var fail_label: RichTextLabel = $FailLabel
@onready var interaction_area: Area2D = $InteractionArea
@onready var floor_hazard_detection_area: Area2D = $FloorHazardDetectionArea

@export var game_camera_path: NodePath

# AUDIO #
@onready var sfx_pool: Node2D = $SFXPool

const BONK_SFX = preload("uid://ivid35oq2etg")
const BONK_VOLUME: float = -5.0
const BONK_PITCH_RANGE: Vector2 = Vector2(0.7, 0.8)

const COLLECT_STAMP_SFX = preload("uid://bpce1xgwwn4rn")
const COLLECT_STAMP_VOLUME: float = -3.0
const COLLECT_STAMP_PITCH_RANGE: Vector2 = Vector2(0.9, 1.2)

const DASH_SFX = preload("uid://cfxseyj0qrubq")
const DASH_VOLUME: float = -5.0
const DASH_PITCH_RANGE: Vector2 = Vector2(0.6, 0.7)

const DEATH_SFX = preload("uid://b8ityln8bof8n")
const DEATH_VOLUME: float = 3.0
const DEATH_PITCH_RANGE: Vector2 = Vector2(0.4, 0.55)

const JUMP_SFX = preload("uid://ckty4lxykwkco")
const JUMP_VOLUME: float = -8.0
const JUMP_PITCH_RANGE: Vector2 = Vector2(0.8, 1.15)

const LAND_SFX = preload("uid://bu8d7x2t5ipm7")
const LAND_VOLUME: float = -10.0
const LAND_PITCH_RANGE: Vector2 = Vector2(0.8, 1.0)
#########

var fail_words: Array = [
	"OUCH!",
	"YIKES!",
	"ROUGH!",
	"U DED!",
	"OOF!",
	"OW!",
	"ACK!",
	"UGH!",
	"SMAAAAASH!",
	"WHAM!",
	"BAM!",
	"OOF!",
	"CRUNCH!",
	"SMACK!",
	"BONK!",
	"YEEOUCH!",
	"OWIE!",
	"JEEZ!",
	"GAH!",
	"EEK!",
	"NOPE!",
	"RIP IN PIECE!",
	"DONEZO!",
	"LIK DIS IF U CRI EVERTIM!"
]

# State
enum PlayerState {
	NORMAL,
	DASH,
	JUMP,
	BONK,
	BOOST,
	GOAL_REACHED,
}

var current_state: PlayerState = PlayerState.NORMAL
var control_enabled: bool = true

###########  Analog  ###########
const ANALOG_PRESS_THRESHOLD: float = 0.55
const ANALOG_RELEASE_THRESHOLD: float = 0.35

var analog_active: bool = false

########### Movement ###########
const NORMAL_SPEED: float = 140.0
const ACCELERATION: float = 450.0
const BRAKING: float = 550.0

var move_input: Vector2 = Vector2.ZERO
var last_move_input: Vector2 = Vector2.RIGHT

# Ice
const ICE_SPEED_MULTIPLIER: float = 1.08
const ICE_ACCELERATION_MULTIPLIER: float = 0.45
const ICE_BRAKING_MULTIPLIER: float = 0.3

var ice_surface_count: int = 0

# Dashing
const DASH_SPEED: float = 220.0
const DASH_DURATION: float = 0.20
const DASH_COOLDOWN: float = 0.30

var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# Jumping
const JUMP_HEIGHT: float = 72.0
const JUMP_DURATION: float = 0.35
const JUMP_COOLDOWN: float = 0.15
const DASH_JUMP_SPEED_MULTIPLIER: float = 1.0
const JUMP_FORWARD_DRAG: float = 120.0
const JUMP_STEER_SPEED: float = 45.0
const JUMP_STEER_ACCELERATION: float = 180.0
const JUMP_OVER_BLOCKER_LAYER : int = 7
const JUMP_BUFFER_TIME: float = 0.08

var jump_buffer_timer: float = 0.0
var jump_buffer_used_this_jump: bool = false
var jumped_from_dash: bool = false
var jump_locked_direction: Vector2 = Vector2.ZERO

const DASH_BUFFER_TIME: float = 0.08

var dash_buffer_timer: float = 0.0
var dash_buffer_used_this_jump: bool = false

# Air movement during jump
const JUMP_MOVE_SPEED: float = 140.0
const JUMP_ACCELERATION: float = 250.0
const JUMP_BRAKING: float = 200.0

var jump_timer: float = 0.0
var jump_cooldown_timer: float = 0.0
var sprite_ground_y: float = 0.0

# Boost
var boost_direction: Vector2 = Vector2.ZERO
var boost_timer: float = 0.0
var boost_speed: float = 0.0

# Bonk
const BONK_REBOUND_SPEED : float = 140.0
const BONK_STUN_DURATION : float = 0.04
const BONK_FALL_SPEED : float = 220.0

var bonk_timer : float = 0.0
var player_sprite_bonk_tween: Tween

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

# Death Clouds
const MIN_DEATH_DUST_TRAVEL_DISTANCE : float = 4.0
const MAX_DEATH_DUST_TRAVEL_DISTANCE : float = 10.0

# Bonk
const BONK = preload("res://scenes/effects/bonk.tscn")
const MIN_BONK_TRAVEL_DISTANCE : float = 4.0
const MAX_BONK_TRAVEL_DISTANCE : float = 12.0

# Jump Cloud
const JUMP_CLOUD = preload("uid://3d6xwo56h5a")

# Landing squash
var sprite_normal_scale: Vector2 = Vector2.ONE
var player_sprite_landing_tween: Tween
var shadow_sprite_landing_tween: Tween

# Camera
@onready var camera_reference: GameCamera = get_node(game_camera_path)

# Jump Interactions
var safe_platform_count: int = 0
var safe_platforms: Array[MovingPlatform] = []

var overlapping_floor_hazard_count: int = 0
var overlapping_hazard_count: int = 0
var goal_overlapping: bool = false

const SAFE_PLATFORM_GRACE_TIME: float = 0.05
var safe_platform_grace_timer: float = 0.0

func _ready() -> void:
	sprite_ground_y = player_sprite.position.y
	sprite_normal_scale = player_sprite.scale
	fail_label.visible = false
	
	var skin_id = SaveManager.get_selected_skin("player")
	var skin = SkinDatabase.retrieve_skin_texture("player", skin_id)
	player_sprite.texture = skin

func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled

func _physics_process(delta: float) -> void:
	if not control_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
	
	if dash_buffer_timer > 0.0:
		dash_buffer_timer -= delta
	
	if safe_platform_grace_timer > 0.0:
		safe_platform_grace_timer -= delta
	
	move_input = get_move_input()
	
	
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
			try_consume_dash_buffer()
			try_start_jump()
			

		PlayerState.DASH:
			handle_dash(delta)
			try_start_jump()

		PlayerState.JUMP:
			handle_jump(delta)
			try_start_dash()
			try_start_jump()
		
		PlayerState.BONK:
			handle_bonk(delta)
		
		PlayerState.BOOST:
			handle_boost(delta)
			try_start_dash()
			try_start_jump()
			
		
	move_and_slide()
	apply_platform_movement()
	check_if_should_die()
	
	if current_state == PlayerState.DASH or current_state == PlayerState.BOOST or (current_state == PlayerState.JUMP and jumped_from_dash):
		check_for_bonk()
	
func get_move_input() -> Vector2:
	var digital_input := Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		digital_input.x -= 1.0
	if Input.is_action_pressed("move_right"):
		digital_input.x += 1.0
	if Input.is_action_pressed("move_up"):
		digital_input.y -= 1.0
	if Input.is_action_pressed("move_down"):
		digital_input.y += 1.0
	
	if digital_input != Vector2.ZERO:
		analog_active = false
		return digital_input.normalized()
	
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	var strength := stick.length()
	
	if not analog_active:
		if strength < ANALOG_PRESS_THRESHOLD:
			return Vector2.ZERO
		analog_active = true
	
	if strength < ANALOG_RELEASE_THRESHOLD:
		analog_active = false
		return Vector2.ZERO
	
	var analog_input := Vector2.ZERO
	
	if stick.x < -ANALOG_PRESS_THRESHOLD:
		analog_input.x = -1.0
	elif stick.x > ANALOG_PRESS_THRESHOLD:
		analog_input.x = 1.0
	
	if stick.y < -ANALOG_PRESS_THRESHOLD:
		analog_input.y = -1.0
	elif stick.y > ANALOG_PRESS_THRESHOLD:
		analog_input.y = 1.0
	
	return analog_input.normalized()

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
		PlayerState.GOAL_REACHED:
			target_rotation_speed = 0.0
			
			current_rotation_speed = move_toward(
				current_rotation_speed,
				target_rotation_speed,
				ROTATION_SPEED_CHANGE_RATE * delta
			)
	
	player_sprite.rotation_degrees += current_rotation_speed * delta
	shadow_sprite.rotation_degrees += current_rotation_speed * delta

func die() -> void:
	if not player_sprite.visible:
		return
	
	player_sprite.visible = false
	shadow_sprite.visible = false
	control_enabled = false
	
	interaction_area.set_deferred("monitorable", false)
	interaction_area.set_deferred("monitoring", false)
	
	floor_hazard_detection_area.set_deferred("monitorable", false)
	floor_hazard_detection_area.set_deferred("monitoring", false)
	
	play_sfx(DEATH_SFX, DEATH_VOLUME, DEATH_PITCH_RANGE)
	spawn_death_clouds(8)
	show_fail_label()
	
	died.emit()

func check_if_should_die() -> void:
	if current_state == PlayerState.JUMP:
		return
	
	if overlapping_hazard_count > 0:
		die()
	
	if safe_platform_count > 0:
		return
	
	if safe_platform_grace_timer > 0.0:
		return
	
	if ice_surface_count > 0:
		return
	
	if overlapping_floor_hazard_count > 0:
		die()

func retry_level() -> void:
	current_state = PlayerState.NORMAL
	current_rotation_speed = 0.0
	rotation_degrees = 0.0
	player_sprite.position.y = sprite_ground_y
	velocity = Vector2.ZERO
	
	set_jump_over_blockers_enabled(true)
	
	dash_cooldown_timer = 0.0
	
	interaction_area.monitorable = true
	interaction_area.monitoring = true
	
	floor_hazard_detection_area.monitorable = true
	floor_hazard_detection_area.monitoring = true
	
	player_sprite.visible = true
	shadow_sprite.visible = true
	hide_fail_label()

func spawn_death_clouds(number_of_clouds: int) -> void:
	for cloud in number_of_clouds:
		var dust_cloud_instance = DUST_CLOUD.instantiate()
		
		get_parent().add_child(dust_cloud_instance)
		dust_cloud_instance.global_position = global_position
		
		var random_travel_distance: float = randf_range(MIN_DEATH_DUST_TRAVEL_DISTANCE, MAX_DEATH_DUST_TRAVEL_DISTANCE)
		
		var spread_angle := deg_to_rad(60.0) # total spread range
		var random_angle := randf_range(-spread_angle, spread_angle)
		var random_direction = Vector2.UP.rotated(randf_range(0, TAU))
		var spread_direction := (random_direction).rotated(random_angle)
		
		dust_cloud_instance.move_to(random_travel_distance, spread_direction)

func handle_normal_movement(delta: float) -> void:
	var on_ice := ice_surface_count > 0
	
	var current_speed := NORMAL_SPEED
	var current_acceleration := ACCELERATION
	var current_braking := BRAKING
	
	if on_ice:
		current_speed *= ICE_SPEED_MULTIPLIER
		current_acceleration *= ICE_ACCELERATION_MULTIPLIER
		current_braking *= ICE_BRAKING_MULTIPLIER
	
	if move_input != Vector2.ZERO:
		var target_velocity := move_input * current_speed
		velocity = velocity.move_toward(target_velocity, current_acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_braking * delta)

func apply_platform_movement() -> void:
	if current_state == PlayerState.JUMP:
		return
	
	if safe_platforms.is_empty():
		return
	
	global_position += safe_platforms[0].movement_delta

func try_start_dash() -> void:
	if not Input.is_action_just_pressed("dash"):
		return

	# No air dash
	if current_state == PlayerState.JUMP:
		if not dash_buffer_used_this_jump:
			dash_buffer_timer = DASH_BUFFER_TIME
			dash_buffer_used_this_jump = true
		return

	if dash_cooldown_timer > 0.0:
		dash_buffer_timer = DASH_BUFFER_TIME
		return
	
	start_dash()

func try_consume_dash_buffer() -> void:
	if dash_buffer_timer <= 0.0:
		return
	
	if dash_cooldown_timer > 0.0:
		return
	
	if current_state != PlayerState.NORMAL:
		return
	
	start_dash()

func start_dash() -> void:
	current_state = PlayerState.DASH
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	dash_buffer_timer = 0.0

	dash_direction = last_move_input.normalized()
	velocity = dash_direction * DASH_SPEED
	
	camera_reference.add_shake(3.0)
	play_sfx(DASH_SFX, DASH_VOLUME, DASH_PITCH_RANGE)
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

func spawn_bonk_effects(direction: Vector2, number_of_bonks: int = 3) -> void:
	for bonk in number_of_bonks:
		var bonk_instance = BONK.instantiate()
		
		get_parent().add_child(bonk_instance)
		bonk_instance.global_position = global_position
		
		var random_travel_distance: float = randf_range(MIN_BONK_TRAVEL_DISTANCE, MAX_BONK_TRAVEL_DISTANCE)
		
		var spread_angle := deg_to_rad(70.0)
		var random_angle := randf_range(-spread_angle, spread_angle)
		
		var spread_direction := (-direction).rotated(random_angle)
		
		bonk_instance.move_to(random_travel_distance, spread_direction)
		
func handle_dash(delta: float) -> void:
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED

	if dash_timer <= 0.0:
		current_state = PlayerState.NORMAL

func check_for_bonk() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		
		var impact_direction := dash_direction
		if current_state == PlayerState.JUMP:
			impact_direction = jump_locked_direction
		
		if impact_direction.dot(-normal) > 0.65:
			start_bonk(normal)
			return

func start_bonk(wall_normal: Vector2) -> void:
	play_sfx(BONK_SFX, BONK_VOLUME, BONK_PITCH_RANGE)
	current_state = PlayerState.BONK
	bonk_timer = BONK_STUN_DURATION
	
	var jump_cloud_instance = JUMP_CLOUD.instantiate()
	get_parent().add_child(jump_cloud_instance)
	jump_cloud_instance.scale *= 0.8
	jump_cloud_instance.global_position = global_position
	
	spawn_bonk_effects(wall_normal, 3)
	
	velocity = wall_normal * BONK_REBOUND_SPEED
	dash_timer = 0.0
	jump_timer = 0.0
	jumped_from_dash = false
	
	camera_reference.add_shake(3.0)
	play_bonk_squash(wall_normal)

func handle_bonk(delta: float) -> void:
	bonk_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	
	player_sprite.position.y = move_toward(
		player_sprite.position.y,
		sprite_ground_y,
		BONK_FALL_SPEED * delta
	)
	
	var sprite_is_grounded := is_equal_approx(player_sprite.position.y, sprite_ground_y)
	
	if bonk_timer <= 0.0 and sprite_is_grounded:
		player_sprite.position.y = sprite_ground_y
		shadow_sprite.scale = Vector2.ONE
		shadow_sprite.modulate.a = 1.0
		set_jump_over_blockers_enabled(true)
		current_state = PlayerState.NORMAL

func play_bonk_squash(wall_normal: Vector2) -> void:
	if player_sprite_bonk_tween:
		player_sprite_bonk_tween.kill()
	
	player_sprite.scale = sprite_normal_scale
	
	var squash_scale: Vector2
	
	if abs(wall_normal.x) > abs(wall_normal.y):
		# Hit left/right wall, squash horizontally.
		squash_scale = Vector2(sprite_normal_scale.x * 0.75, sprite_normal_scale.y * 1.25)
	else:
		# Hit top/bottom wall, squash vertically.
		squash_scale = Vector2(sprite_normal_scale.x * 1.25, sprite_normal_scale.y * 0.75)
	
	player_sprite_bonk_tween = create_tween()
	player_sprite_bonk_tween.tween_property(player_sprite, "scale", squash_scale, 0.04)
	player_sprite_bonk_tween.chain().tween_property(player_sprite, "scale", sprite_normal_scale, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func start_boost(direction: Vector2, speed: float, duration: float) -> void:
	current_state = PlayerState.BOOST
	boost_direction = direction.normalized()
	boost_speed = speed
	boost_timer = duration
	
	dash_direction = boost_direction # lets your existing bonk logic reuse direction
	velocity = boost_direction * boost_speed
	
	camera_reference.add_shake(2.5)
	spawn_dash_clouds(boost_direction)

func handle_boost(delta: float) -> void:
	boost_timer -= delta
	velocity = boost_direction * boost_speed
	
	if boost_timer <= 0.0:
		current_state = PlayerState.NORMAL

func try_start_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	
	if current_state == PlayerState.JUMP:
		if not jump_buffer_used_this_jump:
			jump_buffer_timer = JUMP_BUFFER_TIME
			jump_buffer_used_this_jump = true
		return

	if jump_cooldown_timer > 0.0:
		return
	
	start_jump()

func start_jump() -> void:
	jumped_from_dash = current_state == PlayerState.DASH

	current_state = PlayerState.JUMP
	jump_timer = JUMP_DURATION
	jump_cooldown_timer = JUMP_COOLDOWN
	
	jump_buffer_timer = 0.0
	jump_buffer_used_this_jump = false
	
	dash_buffer_timer = 0.0
	dash_buffer_used_this_jump = false
	
	set_jump_over_blockers_enabled(false)
	
	if jumped_from_dash:
		jump_locked_direction = dash_direction
		velocity = jump_locked_direction * DASH_SPEED
	else:
		if velocity.length() > 0.0:
			jump_locked_direction = velocity.normalized()
		else:
			jump_locked_direction = last_move_input.normalized()
	
	play_sfx(JUMP_SFX, JUMP_VOLUME, JUMP_PITCH_RANGE)
	
	player_jumped.emit()
	
	var jump_cloud_instance = JUMP_CLOUD.instantiate()
	get_parent().add_child(jump_cloud_instance)
	jump_cloud_instance.global_position = global_position

func set_jump_over_blockers_enabled(enabled: bool) -> void:
	set_collision_mask_value(JUMP_OVER_BLOCKER_LAYER, enabled)

func handle_jump(delta: float) -> void:
	jump_timer -= delta

	# Preserve forward momentum, especially for dash-jumps
	var forward_velocity := jump_locked_direction * velocity.dot(jump_locked_direction)
	forward_velocity = forward_velocity.move_toward(Vector2.ZERO, JUMP_FORWARD_DRAG * delta)

	# Small steering influence only
	var steer_velocity := Vector2.ZERO
	if move_input != Vector2.ZERO:
		var steer_target := move_input * JUMP_STEER_SPEED
		steer_velocity = Vector2.ZERO.move_toward(steer_target, JUMP_STEER_ACCELERATION * delta)

	velocity = forward_velocity + steer_velocity

	# Visual jump arc
	var progress := 1.0 - (jump_timer / JUMP_DURATION)
	progress = clamp(progress, 0.0, 1.0)

	var height := JUMP_HEIGHT * progress * (1.0 - progress)
	player_sprite.position.y = sprite_ground_y - height

	var height_ratio := height / JUMP_HEIGHT
	var shadow_scale = lerp(1.0, SHADOW_MIN_SCALE, height_ratio)
	shadow_sprite.scale = Vector2(shadow_scale, shadow_scale * 0.9)
	shadow_sprite.modulate.a = lerp(1.0, 0.6, height_ratio)

	if jump_timer <= 0.0:
		player_sprite.position.y = sprite_ground_y
		shadow_sprite.scale = Vector2.ONE
		shadow_sprite.modulate.a = 1.0
		play_landing_squash()
		camera_reference.add_shake(2.0)
		current_state = PlayerState.NORMAL
		
		play_sfx(LAND_SFX, LAND_VOLUME, LAND_PITCH_RANGE)
		
		set_jump_over_blockers_enabled(true)
		
		if overlapping_hazard_count > 0:
			die()
			return
		
		if overlapping_floor_hazard_count > 0 and safe_platform_count == 0 and ice_surface_count == 0:
			die()
			return
		
		if goal_overlapping:
			try_to_activate_goal()
			return
		
		if dash_buffer_timer > 0.0:
			start_dash()
			return
		
		if jump_buffer_timer > 0.0:
			start_jump()
			return

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
	


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		overlapping_hazard_count += 1

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		overlapping_hazard_count = max(0, overlapping_hazard_count - 1)


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("goal"):
		goal_overlapping = true
		
		if current_state == PlayerState.JUMP:
			return
		
		try_to_activate_goal()
	
	if area.is_in_group("hazards"):
		overlapping_hazard_count += 1
		
	if area.is_in_group("safe_platforms"):
		if area is MovingPlatform and not safe_platforms.has(area):
			safe_platforms.append(area)
		safe_platform_count += 1
	
	if area.is_in_group("ice_surfaces"):
		ice_surface_count += 1


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("goal"):
		goal_overlapping = false
	
	if area.is_in_group("hazards"):
		overlapping_hazard_count = max(0, overlapping_hazard_count - 1)
	
	if area.is_in_group("safe_platforms"):
		if area is MovingPlatform:
			safe_platforms.erase(area)
		
		safe_platform_count = max(0, safe_platform_count - 1)
		safe_platform_grace_timer = SAFE_PLATFORM_GRACE_TIME
	
	if area.is_in_group("ice_surfaces"):
		ice_surface_count = max(0, ice_surface_count - 1)

func _on_floor_hazard_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("floor_hazards"):
		overlapping_floor_hazard_count += 1
	
	if body.is_in_group("ice_surfaces"):
		ice_surface_count += 1


func _on_floor_hazard_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("floor_hazards"):
		overlapping_floor_hazard_count = max(0, overlapping_floor_hazard_count - 1)
	
	if body.is_in_group("ice_surfaces"):
		ice_surface_count = max(0, ice_surface_count - 1)

func _on_stamp_collection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("stamps"):
		if get_tree().get_node_count_in_group("stamps") > 1:
			play_sfx(COLLECT_STAMP_SFX, COLLECT_STAMP_VOLUME, COLLECT_STAMP_PITCH_RANGE)
		
		area.collect()

func show_fail_label() -> void:
	var random_word = fail_words.pick_random()
	fail_label.text = "[shake]" + random_word.to_upper() + "[/shake]"
	fail_label.visible = true

func hide_fail_label() -> void:
	fail_label.visible = false

func try_to_activate_goal() -> void:
	var stamps_remaining = get_tree().get_node_count_in_group("stamps")
	if stamps_remaining > 0:
		return
	
	goal_reached.emit()
	current_state = PlayerState.GOAL_REACHED
	player_sprite.visible = false
	shadow_sprite.visible = false

####### AUDIO HANDLING ########
func play_sfx(sfx: AudioStream, volume_db: float = 0.0, pitch_range: Vector2 = Vector2(0.95, 1.05)):
	for audio_player: AudioStreamPlayer2D in sfx_pool.get_children():
		if not audio_player.playing:
			audio_player.volume_db = volume_db
			audio_player.stream = sfx
			audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
			audio_player.play()
			return
###############################
