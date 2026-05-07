extends Area2D
class_name StickyPlatform

var triggered: bool = false

var player_reference: Player
var checking_for_player_landing: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if triggered:
		return
	
	if not checking_for_player_landing:
		return
	
	if player_reference:
		if player_reference.player_sprite.position.y == player_reference.sprite_ground_y:
			player_reference.velocity = Vector2.ZERO
			checking_for_player_landing = false
			triggered = true
	
func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	
	if not body.is_in_group("player"):
		return
	
	player_reference = body
	checking_for_player_landing = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		triggered = false
	
	player_reference = null
