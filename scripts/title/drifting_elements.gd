extends Node2D

@export var textures: Array[Texture2D] = []

@export var spawn_interval: float = 1.4
@export var max_elements: int = 12

@export var spawn_initial_elements: bool = true
@export var initial_element_count: int = 8

@export var min_speed: float = 8.0
@export var max_speed: float = 18.0

@export var min_scale: float = 0.6
@export var max_scale: float = 1.3

@export var min_alpha: float = 0.10
@export var max_alpha: float = 0.22

@export var rotation_speed_min: float = -45.0
@export var rotation_speed_max: float = 45.0

@export var logo_safe_zone: Rect2 = Rect2(Vector2(70, 5), Vector2(180, 75))
@export var debug_draw_safe_zone: bool = false

@export var horizontal_drift_min: float = -6.0
@export var horizontal_drift_max: float = 6.0

var timer: float = 0.0
var active_elements: Array[Sprite2D] = []


func _ready() -> void:
	if spawn_initial_elements:
		spawn_initial_drifting_elements()


func _draw() -> void:
	if not debug_draw_safe_zone:
		return
	
	draw_rect(logo_safe_zone, Color(1, 0, 0, 0.2), true)
	draw_rect(logo_safe_zone, Color(1, 0, 0, 0.8), false)


func _process(delta: float) -> void:
	if debug_draw_safe_zone:
		queue_redraw()
	
	timer -= delta
	
	if timer <= 0.0:
		timer = spawn_interval
		spawn_drifting_element(false)
	
	update_elements(delta)


func spawn_initial_drifting_elements() -> void:
	for i in initial_element_count:
		spawn_drifting_element(true)


func spawn_drifting_element(start_on_screen: bool = false) -> void:
	if textures.is_empty():
		return
	
	if active_elements.size() >= max_elements:
		return
	
	var sprite := Sprite2D.new()
	add_child(sprite)
	active_elements.append(sprite)
	
	sprite.texture = textures.pick_random()
	sprite.centered = true
	
	var viewport_size := get_viewport_rect().size
	var spawn_position := get_spawn_position(viewport_size, start_on_screen)
	
	sprite.global_position = spawn_position
	
	var upward_speed := randf_range(min_speed, max_speed)
	var horizontal_drift := randf_range(horizontal_drift_min, horizontal_drift_max)
	sprite.set_meta("velocity", Vector2(horizontal_drift, -upward_speed))
	
	var s := randf_range(min_scale, max_scale)
	sprite.scale = Vector2(s, s)
	sprite.rotation_degrees = randf_range(0.0, 360.0)
	
	var base_alpha := randf_range(min_alpha, max_alpha)
	sprite.modulate.a = base_alpha
	sprite.set_meta("base_alpha", base_alpha)
	
	var speed_sign: float = -1.0 if randf() < 0.5 else 1.0
	var max_abs_rotation_speed = max(abs(rotation_speed_min), abs(rotation_speed_max))
	var rot_speed := randf_range(20.0, max_abs_rotation_speed) * speed_sign
	sprite.set_meta("rotation_speed", rot_speed)


func get_spawn_position(viewport_size: Vector2, start_on_screen: bool) -> Vector2:
	var spawn_position: Vector2
	
	if start_on_screen:
		spawn_position = Vector2(
			randf_range(20.0, viewport_size.x - 20.0),
			randf_range(20.0, viewport_size.y - 20.0)
		)
	else:
		spawn_position = Vector2(
			randf_range(20.0, viewport_size.x - 20.0),
			viewport_size.y + 40.0
		)
	
	var attempts := 0
	while logo_safe_zone.has_point(spawn_position) and attempts < 20:
		if start_on_screen:
			spawn_position = Vector2(
				randf_range(20.0, viewport_size.x - 20.0),
				randf_range(20.0, viewport_size.y - 20.0)
			)
		else:
			spawn_position = Vector2(
				randf_range(20.0, viewport_size.x - 20.0),
				viewport_size.y + 40.0
			)
		
		attempts += 1
	
	return spawn_position


func update_elements(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	
	for i in range(active_elements.size() - 1, -1, -1):
		var sprite := active_elements[i]
		
		if not is_instance_valid(sprite):
			active_elements.remove_at(i)
			continue
		
		var velocity: Vector2 = sprite.get_meta("velocity")
		var rotation_speed: float = sprite.get_meta("rotation_speed")
		
		sprite.global_position += velocity * delta
		sprite.rotation_degrees += rotation_speed * delta
		
		if sprite.global_position.x < -60.0 \
		or sprite.global_position.x > viewport_size.x + 60.0 \
		or sprite.global_position.y < -60.0:
			active_elements.remove_at(i)
			sprite.queue_free()
