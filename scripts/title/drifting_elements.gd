extends Node2D

@export var textures: Array[Texture2D] = []
@export var spawn_interval: float = 1.4
@export var max_elements: int = 12

@export var min_speed: float = 8.0
@export var max_speed: float = 18.0

@export var min_scale: float = 0.6
@export var max_scale: float = 1.3

@export var min_alpha: float = 0.10
@export var max_alpha: float = 0.22

@export var rotation_speed_min: float = -45.0
@export var rotation_speed_max: float = 45.0

# Area where elements should NOT spawn/pass through.
# Adjust these based on your title logo/menu placement.
@export var logo_safe_zone: Rect2 = Rect2(Vector2(70, 5), Vector2(180, 75))

# Side drift while moving upward.
@export var horizontal_drift_min: float = -6.0
@export var horizontal_drift_max: float = 6.0

var timer: float = 0.0
var active_elements: Array[Sprite2D] = []

@export var debug_draw_safe_zone: bool = true

func _draw() -> void:
	if not debug_draw_safe_zone:
		return
	
	draw_rect(logo_safe_zone, Color(1, 0, 0, 0.2), true)   # filled
	draw_rect(logo_safe_zone, Color(1, 0, 0, 0.8), false)  # outline

func _process(delta: float) -> void:
	queue_redraw()
	
	timer -= delta
	
	if timer <= 0.0:
		timer = spawn_interval
		spawn_drifting_element()
	
	update_elements(delta)


func spawn_drifting_element() -> void:
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
	
	# Spawn just below the screen.
	var spawn_position := Vector2(
		randf_range(20, viewport_size.x - 20),
		viewport_size.y + 40
	)
	
	# Avoid spawning directly under the logo area.
	var attempts := 0
	while logo_safe_zone.has_point(spawn_position) and attempts < 20:
		spawn_position.x = randf_range(20, viewport_size.x - 20)
		attempts += 1
	
	sprite.global_position = spawn_position
	
	var upward_speed := randf_range(min_speed, max_speed)
	var horizontal_drift := randf_range(horizontal_drift_min, horizontal_drift_max)
	sprite.set_meta("velocity", Vector2(horizontal_drift, -upward_speed))
	
	var s := randf_range(min_scale, max_scale)
	sprite.scale = Vector2(s, s)
	sprite.rotation_degrees = randf_range(0.0, 360.0)
	sprite.modulate.a = randf_range(min_alpha, max_alpha)
	
	var speed_sign: float = -1.0 if randf() < 0.5 else 1.0
	var rot_speed := randf_range(20.0, rotation_speed_max) * speed_sign
	sprite.set_meta("rotation_speed", rot_speed)


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
		
		if sprite.global_position.x < -60 \
		or sprite.global_position.x > viewport_size.x + 60 \
		or sprite.global_position.y < -60:
			active_elements.remove_at(i)
			sprite.queue_free()
