@tool
extends Area2D
class_name LaserHazard

enum LaserState {
	OFF,
	WARNING,
	ACTIVE
}

@onready var left_cap_sprite: Sprite2D = $Caps/LeftCap/LeftCapSprite
@onready var right_cap_sprite: Sprite2D = $Caps/RightCap/RightCapSprite
@onready var beam: Line2D = $Beam
@onready var warning_beam: Line2D = $WarningBeam
@onready var beam_collision: CollisionShape2D = $BeamCollision
@onready var l_cap_particles: GPUParticles2D = $LCapParticles
@onready var r_cap_particles: GPUParticles2D = $RCapParticles

@export var warning_time: float = 0.3
@export var active_time: float = 0.35
@export var off_time: float = 0.35
@export var phase_offset: float = 0.0
@export var start_in_active_phase: bool = false

@export_group("Editor Preview")
@export var preview_in_editor: bool = true
@export_range(0.0, 1.0, 0.01) var preview_cycle_position: float = 0.0:
	set(value):
		preview_cycle_position = clamp(value, 0.0, 1.0)
		if Engine.is_editor_hint():
			update_laser()
			apply_state_immediate(get_target_state(true))

var cap_tween: Tween
var beam_tween: Tween
var warning_tween: Tween

var current_state: LaserState = LaserState.OFF


func _ready() -> void:
	update_laser()

	if Engine.is_editor_hint():
		apply_state_immediate(get_target_state(true))
		return

	apply_state_immediate(get_target_state(false))


func _process(_delta: float) -> void:
	update_laser()

	if Engine.is_editor_hint():
		if not preview_in_editor:
			apply_state_immediate(LaserState.OFF)
			return

		var editor_state := get_target_state(true)
		if editor_state != current_state:
			apply_state_immediate(editor_state)
		return

	var target_state := get_target_state(false)
	if target_state != current_state:
		change_state(target_state)


func update_laser() -> void:
	if not is_node_ready():
		return
	if not left_cap_sprite or not right_cap_sprite or not beam or not warning_beam:
		return

	var start_pos := beam.to_local(left_cap_sprite.global_position)
	var end_pos := beam.to_local(right_cap_sprite.global_position)

	beam.clear_points()
	beam.add_point(start_pos)
	beam.add_point(end_pos)
	
	l_cap_particles.position = start_pos
	r_cap_particles.position = end_pos
	
	var warning_start := warning_beam.to_local(left_cap_sprite.global_position)
	var warning_end := warning_beam.to_local(right_cap_sprite.global_position)

	warning_beam.clear_points()
	warning_beam.add_point(warning_start)
	warning_beam.add_point(warning_end)

	update_collision_shape()


func update_collision_shape() -> void:
	if not beam_collision or not beam_collision.shape is RectangleShape2D:
		return

	var start_pos := to_local(left_cap_sprite.global_position)
	var end_pos := to_local(right_cap_sprite.global_position)
	var delta := end_pos - start_pos
	var length := delta.length()

	var rect_shape := beam_collision.shape as RectangleShape2D
	rect_shape.size.x = length
	rect_shape.size.y = max(6.0, 2.0)

	beam_collision.position = start_pos + delta * 0.5
	beam_collision.rotation = delta.angle()


func get_target_state(use_editor_preview: bool) -> LaserState:
	var cycle_length := warning_time + active_time + off_time
	if cycle_length <= 0.0:
		return LaserState.OFF

	var t: float

	if use_editor_preview:
		t = preview_cycle_position * cycle_length
	else:
		t = fposmod(Time.get_ticks_msec() / 1000.0 + phase_offset, cycle_length)

	if start_in_active_phase:
		t = fposmod(t + warning_time, cycle_length)

	if t < warning_time:
		return LaserState.WARNING
	elif t < warning_time + active_time:
		return LaserState.ACTIVE
	else:
		return LaserState.OFF


func change_state(new_state: LaserState) -> void:
	match new_state:
		LaserState.WARNING:
			show_warning()
		LaserState.ACTIVE:
			appear()
		LaserState.OFF:
			disappear()


func apply_state_immediate(new_state: LaserState) -> void:
	kill_tweens()
	current_state = new_state

	match new_state:
		LaserState.WARNING:
			beam.visible = false
			beam.width = 0.0
			warning_beam.visible = true
			beam_collision.disabled = true

			if not Engine.is_editor_hint():
				l_cap_particles.emitting = false
				r_cap_particles.emitting = false

			left_cap_sprite.scale = Vector2.ONE
			right_cap_sprite.scale = Vector2.ONE
			warning_beam.modulate.a = 0.65

		LaserState.ACTIVE:
			beam.visible = true
			beam.width = 2.0
			warning_beam.visible = false
			beam_collision.disabled = false

			if not Engine.is_editor_hint():
				l_cap_particles.emitting = true
				r_cap_particles.emitting = true

			left_cap_sprite.scale = Vector2.ONE
			right_cap_sprite.scale = Vector2.ONE

		LaserState.OFF:
			beam.visible = false
			beam.width = 0.0
			warning_beam.visible = false
			beam_collision.disabled = true

			if not Engine.is_editor_hint():
				l_cap_particles.emitting = false
				r_cap_particles.emitting = false

			left_cap_sprite.scale = Vector2.ONE
			right_cap_sprite.scale = Vector2.ONE

	update_collision_shape()


func show_warning() -> void:
	kill_tweens()

	current_state = LaserState.WARNING
	beam.visible = false
	beam.width = 0.0
	warning_beam.visible = true
	beam_collision.disabled = true

	l_cap_particles.emitting = false
	r_cap_particles.emitting = false

	left_cap_sprite.scale = Vector2.ONE
	right_cap_sprite.scale = Vector2.ONE
	warning_beam.modulate.a = 0.2

	warning_tween = create_tween()
	warning_tween.set_parallel(true)
	warning_tween.tween_property(warning_beam, "modulate:a", 0.75, warning_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	warning_tween.tween_property(left_cap_sprite, "scale", Vector2(1.08, 1.08), warning_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	warning_tween.tween_property(right_cap_sprite, "scale", Vector2(1.08, 1.08), warning_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func appear() -> void:
	kill_tweens()

	current_state = LaserState.ACTIVE
	beam.visible = true
	warning_beam.visible = false
	beam_collision.disabled = false

	l_cap_particles.restart()
	r_cap_particles.restart()
	l_cap_particles.emitting = true
	r_cap_particles.emitting = true

	left_cap_sprite.scale = Vector2.ONE
	right_cap_sprite.scale = Vector2.ONE
	beam.width = 0.0
	update_collision_shape()

	cap_tween = create_tween()
	cap_tween.set_parallel(true)
	cap_tween.tween_property(left_cap_sprite, "scale", Vector2(0.7, 1.2), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	cap_tween.tween_property(right_cap_sprite, "scale", Vector2(0.7, 1.2), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	beam_tween = create_tween()
	beam_tween.tween_property(beam, "width", 4.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	beam_tween.tween_callback(update_collision_shape)
	beam_tween.tween_property(beam, "width", 2.0, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	beam_tween.tween_callback(update_collision_shape)

	await cap_tween.finished

	if current_state != LaserState.ACTIVE:
		return

	cap_tween = create_tween()
	cap_tween.set_parallel(true)
	cap_tween.tween_property(left_cap_sprite, "scale", Vector2(1.2, 0.9), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	cap_tween.tween_property(right_cap_sprite, "scale", Vector2(1.2, 0.9), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await cap_tween.finished

	if current_state != LaserState.ACTIVE:
		return

	cap_tween = create_tween()
	cap_tween.set_parallel(true)
	cap_tween.tween_property(left_cap_sprite, "scale", Vector2.ONE, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	cap_tween.tween_property(right_cap_sprite, "scale", Vector2.ONE, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func disappear() -> void:
	kill_tweens()

	current_state = LaserState.OFF
	beam_collision.disabled = true
	warning_beam.visible = false
	l_cap_particles.emitting = false
	r_cap_particles.emitting = false

	beam_tween = create_tween()
	beam_tween.tween_property(beam, "width", 3.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	beam_tween.tween_callback(update_collision_shape)
	beam_tween.tween_property(beam, "width", 0.0, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	beam_tween.tween_callback(update_collision_shape)

	await beam_tween.finished

	if current_state != LaserState.OFF:
		return

	beam.visible = false
	left_cap_sprite.scale = Vector2.ONE
	right_cap_sprite.scale = Vector2.ONE


func kill_tweens() -> void:
	if cap_tween:
		cap_tween.kill()
	if beam_tween:
		beam_tween.kill()
	if warning_tween:
		warning_tween.kill()
