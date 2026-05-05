extends Node2D

@export var length: int = 5
@export var rotation_speed: float = 600.0


@onready var right_blade: Node2D = $RightBlade
@onready var left_blade: Node2D = $LeftBlade
@onready var top_blade: Node2D = $TopBlade
@onready var bottom_blade: Node2D = $BottomBlade

var blades: Array[Node2D] = []

func _ready() -> void:
	rotation_degrees = 0.0
	
	if blades.is_empty():
		blades = [right_blade, left_blade, top_blade, bottom_blade]
	
	setup_blade_lengths()

func setup_blade_lengths() -> void:
	for blade in blades:
		var blade_squares = blade.get_children()
		
		for i in range(blade_squares.size() - 1, length - 1, -1):
			blade_squares[i].queue_free()
			

func _process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta
