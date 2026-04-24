extends CharacterBody2D
class_name Player

signal died
signal goal_reached

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var fail_label: RichTextLabel = $FailLabel
@onready var interaction_area: Area2D = $InteractionArea
@onready var floor_hazard_detection_area: Area2D = $FloorHazardDetectionArea

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
	GOAL_REACHED,
}

var current_state: PlayerState = PlayerState.NORMAL
var control_enabled: bool = true
const ANALOG_DEADZONE: float = 0.18

########### Movement ###########
const NORMAL_SPEED: float = 140.0
const ACCELERATION: float = 450.0
const BRAKING: float = 350.0

var move_input: Vector2 = Vector2.ZERO
var last_move_input: Vector2 = Vector2.RIGHT

# Dashing
const DASH_SPEED: float = 220.0
const DASH_DURATION: float = 0.20
const DASH_COOLDOWN: float = 0.35

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


var jumped_from_dash: bool = false
var jump_locked_direction: Vector2 = Vector2.ZERO

# Air movement during jump
const JUMP_MOVE_SPEED: float = 140.0
const JUMP_ACCELERATION: float = 250.0
const JUMP_BRAKING: float = 200.0

var jump_timer: float = 0.0
var jump_cooldown_timer: float = 0.0
var sprite_ground_y: float = 0.0

# Bonk
const BONK_REBOUND_SPEED : float = 140.0
const BONK_STUN_DURATION : float = 0.08
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
var camera_reference: GameCamera

# Jump Interactions
var overlapping_hazard_count: int = 0
var overlapping_stamp: Stamp = null
var goal_overlapping: bool = false

func _ready() -> void:
	sprite_ground_y = player_sprite.position.y
	sprite_normal_scale = player_sprite.scale
	camera_reference = get_tree().get_first_node_in_group("game_camera")
	fail_label.visible = false

func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled

func get_movement_input() -> Vector2:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down",
		ANALOG_DEADZONE
	)
	
	if input_vector.length() < ANALOG_DEADZONE:
		return Vector2.ZERO
	
	return input_vector

func _physics_process(delta: float) -> void:
	if not control_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	move_input = get_movement_input()
	
	
	if move_input.length() > 0.25:
		last_move_input = move_input.normalized()

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if jump_cooldown_timer > 0.0:
		jump_cooldown_timer -= delta
	
	match current_state:
		PlayerState.NORMAL:
			handle_normal_movement(delta)
			try_start_dash()
			try_start_jump()
			check_if_should_die()

		PlayerState.DASH:
			handle_dash(delta)
			try_start_jump()

		PlayerState.JUMP:
			handle_jump(delta)
		
		PlayerState.BONK:
			handle_bonk(delta)

	move_and_slide()
	
	if current_state == PlayerState.DASH or (current_state == PlayerState.JUMP and jumped_from_dash):
		check_for_bonk()
	

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
	
	spawn_death_clouds(8)
	show_fail_label()
	
	died.emit()

func check_if_should_die() -> void:
	if overlapping_hazard_count > 0:
		die()

func retry_level() -> void:
	current_state = PlayerState.NORMAL
	current_rotation_speed = 0.0
	rotation_degrees = 0.0
	player_sprite.position.y = sprite_ground_y
	velocity = Vector2.ZERO
	
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

	#if move_input == Vector2.ZERO:
		#return

	current_state = PlayerState.DASH
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN

	dash_direction = last_move_input.normalized()
	velocity = dash_direction * DASH_SPEED
	
	camera_reference.add_shake(3.0)
	
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
	current_state = PlayerState.BONK
	bonk_timer = BONK_STUN_DURATION
	
	var jump_cloud_instance = JUMP_CLOUD.instantiate()
	get_parent().add_child(jump_cloud_instance)
	jump_cloud_instance.scale *= 0.8
	jump_cloud_instance.global_position = global_position
	
	spawn_bonk_effects(wall_normal, 3)
	
	shadow_sprite.scale = Vector2.ONE
	shadow_sprite.modulate.a = 1.0
	
	velocity = wall_normal * BONK_REBOUND_SPEED
	dash_timer = 0.0
	jump_timer = 0.0
	jumped_from_dash = false
	
	camera_reference.add_shake(3.0)
	play_bonk_squash(wall_normal)

func handle_bonk(delta: float) -> void:
	bonk_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	
	player_sprite.position.y = move_toward(player_sprite.position.y, sprite_ground_y, BONK_FALL_SPEED * delta)
	
	if bonk_timer <= 0.0:
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

func try_start_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return

	if jump_cooldown_timer > 0.0:
		return

	jumped_from_dash = current_state == PlayerState.DASH

	current_state = PlayerState.JUMP
	jump_timer = JUMP_DURATION
	jump_cooldown_timer = JUMP_COOLDOWN

	if jumped_from_dash:
		jump_locked_direction = dash_direction
		velocity = jump_locked_direction * DASH_SPEED
	else:
		if velocity.length() > 0.0:
			jump_locked_direction = velocity.normalized()
		else:
			jump_locked_direction = last_move_input.normalized()

	var jump_cloud_instance = JUMP_CLOUD.instantiate()
	get_parent().add_child(jump_cloud_instance)
	jump_cloud_instance.global_position = global_position


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
		
		if overlapping_hazard_count > 0:
			die()
		
		if overlapping_stamp:
			overlapping_stamp.collect()
			overlapping_stamp = null
		
		if goal_overlapping:
			try_to_activate_goal()
			

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
		if current_state == PlayerState.JUMP:
			return
		die()

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
		if current_state == PlayerState.JUMP:
			return
		die()
	
	if area.is_in_group("stamps"):
		overlapping_stamp = area
		if current_state == PlayerState.JUMP:
			return
		area.collect()


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("goal"):
		goal_overlapping = false
	
	if area.is_in_group("hazards"):
		overlapping_hazard_count = max(0, overlapping_hazard_count - 1)
	
	if area.is_in_group("stamps"):
		overlapping_stamp = null

func _on_floor_hazard_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("floor_hazards"):
		overlapping_hazard_count += 1
		if current_state == PlayerState.JUMP:
			return
		die()


func _on_floor_hazard_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("floor_hazards"):
		overlapping_hazard_count = max(0, overlapping_hazard_count - 1)

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
