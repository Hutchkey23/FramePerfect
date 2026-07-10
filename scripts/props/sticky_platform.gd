extends Area2D
class_name StickyPlatform

var triggered: bool = false

var player_reference: Player
var checking_for_player_landing: bool = false
var entered_from_another_sticky: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if triggered:
		return

	if not checking_for_player_landing:
		return

	if not is_instance_valid(player_reference):
		checking_for_player_landing = false
		return

	var player_is_grounded := is_equal_approx(
		player_reference.player_sprite.position.y,
		player_reference.sprite_ground_y
	)

	if player_is_grounded:
		player_reference.land_on_sticky_platform()

		checking_for_player_landing = false
		triggered = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var player := body as Player
	if player == null:
		return

	player_reference = player

	# Check the count BEFORE adding this platform.
	entered_from_another_sticky = player.sticky_surface_count > 0

	player.sticky_surface_count += 1

	if triggered:
		return

	# The player moved onto this platform while already touching
	# another sticky platform, so preserve their movement.
	if entered_from_another_sticky:
		checking_for_player_landing = false
		return

	# This was the first sticky platform entered, even if another
	# platform is entered later during the same physics frame.
	checking_for_player_landing = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var player := body as Player
	if player == null:
		return

	player.sticky_surface_count = max(
		0,
		player.sticky_surface_count - 1
	)

	if player == player_reference:
		player_reference = null

	checking_for_player_landing = false
	entered_from_another_sticky = false
	triggered = false
