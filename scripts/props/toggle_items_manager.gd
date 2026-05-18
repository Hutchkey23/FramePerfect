extends Node2D

@export var player_path: NodePath

@onready var player_reference: Player = get_node(player_path)

func _ready() -> void:
	setup_toggles()
	
func setup_toggles() -> void:
	for toggle_item in get_children():
		toggle_item.player_reference = player_reference
		
		if not player_reference.player_jumped.is_connected(toggle_item.toggle):
			player_reference.player_jumped.connect(toggle_item.toggle)
