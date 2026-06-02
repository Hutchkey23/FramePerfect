@tool
extends Node2D

@export var length: int = 5:
	set(value):
		length = max(value, 1)
		if is_inside_tree():
			call_deferred("setup_blade_lengths")

@export var rotation_speed: float = 600.0
@export var rotate_squares: bool = true
@export_category("Editor Preview")
@export var preview_rotation: bool = true
@export var reset_rotation_when_preview_off: bool = false

@onready var center: SquareHazard = $Center

@onready var right_blade: Node2D = $RightBlade
@onready var left_blade: Node2D = $LeftBlade
@onready var top_blade: Node2D = $TopBlade
@onready var bottom_blade: Node2D = $BottomBlade

var blades: Array[Node2D] = []


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_process(true)


func _ready() -> void:
	cache_blades()
	setup_blade_lengths()
	set_process(true)
	
	center.should_not_rotate = not rotate_squares
	
	if not Engine.is_editor_hint():
		rotation_degrees = 0.0


func cache_blades() -> void:
	if not is_node_ready():
		return

	blades = [
		right_blade,
		left_blade,
		top_blade,
		bottom_blade
	]


func setup_blade_lengths() -> void:
	if not is_node_ready():
		return

	cache_blades()

	for blade in blades:
		if blade == null:
			continue

		var blade_squares := blade.get_children()

		for i in blade_squares.size():
			var square := blade_squares[i]
			var enabled := i < length
			set_square_enabled(square, enabled)


func set_square_enabled(square, enabled: bool) -> void:
	if square == null:
		return

	square.visible = enabled
	
	square.should_not_rotate = not rotate_squares
	
	if square is Area2D:
		square.monitoring = enabled
		square.monitorable = enabled

	disable_collision_shapes(square, not enabled)


func disable_collision_shapes(node: Node, disabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = disabled
		elif child is CollisionPolygon2D:
			child.disabled = disabled
		else:
			disable_collision_shapes(child, disabled)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if preview_rotation:
			rotation_degrees += rotation_speed * delta
		elif reset_rotation_when_preview_off:
			rotation_degrees = 0.0

		return

	rotation_degrees += rotation_speed * delta
