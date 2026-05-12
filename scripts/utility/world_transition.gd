extends CanvasLayer
class_name WorldTransition

signal transition_in

@export var completed_world_debug: WorldData
@export var next_world_debug: WorldData

@onready var current_world_postcard: WorldTransitionPostcard = $CurrentWorldPostcard
@onready var current_world_background: TextureRect = $CurrentWorldBackground

@onready var next_world_postcard: WorldTransitionPostcard = $NextWorldPostcard
@onready var next_world_background: TextureRect = $NextWorldBackground
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var postcard_tween: Tween

func play_initial_transition(current_world: WorldData) -> void:
	animation_player.play("RESET")
	visible = true
	
	current_world_background.texture = current_world.background_texture
	current_world_postcard.setup(current_world)
	
	await get_tree().create_timer(2.0).timeout

func play_transition(completed_world: WorldData, next_world: WorldData) -> void:
	BGMManager.fade_out(1.5)
	animation_player.play("RESET")
	visible = true
	
	current_world_background.texture = completed_world.background_texture
	next_world_background.texture = next_world.background_texture
	
	current_world_postcard.setup(completed_world)
	next_world_postcard.setup(next_world)
	
	transition_in.emit()
	
	await get_tree().create_timer(1.0).timeout
	await shake_then_pop(current_world_postcard)
	await get_tree().create_timer(1.0).timeout
	
	if next_world.background_music.size() > 0:
		BGMManager.play_world_playlist(next_world.background_music, false)
	
	animation_player.play("transition_to_next_world")
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout

func fade_background_out(background: TextureRect) -> void:
	var mat := background.material as ShaderMaterial
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/fade_alpha", 0.0, 0.5)

func shake_then_pop(postcard: WorldTransitionPostcard) -> void:
	if postcard_tween:
		postcard_tween.kill()

	var base_pos := postcard.position
	var base_scale := postcard.scale
	var base_rotation := postcard.rotation_degrees

	postcard.pivot_offset = postcard.size / 2.0

	postcard_tween = create_tween()

	# Build-up shake
	var shake_steps := 16
	for i in shake_steps:
		var progress := float(i) / float(shake_steps - 1)
		var strength = lerp(1.0, 5.0, progress)
		var rot_strength = lerp(1.0, 4.0, progress)

		var postcard_offset := Vector2(
			randf_range(-strength, strength),
			randf_range(-strength * 0.4, strength * 0.4)
		)

		var rot := randf_range(-rot_strength, rot_strength)

		postcard_tween.tween_property(postcard, "position", base_pos + postcard_offset, 0.035)
		postcard_tween.parallel().tween_property(postcard, "rotation_degrees", base_rotation + rot, 0.035)

	# Snap back for impact
	postcard_tween.tween_property(postcard, "position", base_pos, 0.04)
	postcard_tween.parallel().tween_property(postcard, "rotation_degrees", base_rotation, 0.04)

	# Big pop
	postcard_tween.tween_callback(postcard.change_to_delivered)

	# Huge impact squash
	postcard_tween.parallel().tween_property(
		postcard,
		"scale",
		base_scale * Vector2(1.38, 0.62),
		0.045
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Slight rotation kick
	postcard_tween.parallel().tween_property(
		postcard,
		"rotation_degrees",
		base_rotation + randf_range(-8.0, 8.0),
		0.045
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Explosive rebound
	postcard_tween.parallel().tween_property(
		postcard,
		"scale",
		base_scale * Vector2(0.78, 1.28),
		0.085
	).set_delay(0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Snap back with elastic settle
	postcard_tween.parallel().tween_property(
		postcard,
		"scale",
		base_scale,
		0.32
	).set_delay(0.13).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Rotation settle
	postcard_tween.parallel().tween_property(
		postcard,
		"rotation_degrees",
		base_rotation,
		0.24
	).set_delay(0.13).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await postcard_tween.finished
