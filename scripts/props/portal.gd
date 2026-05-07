extends Area2D
class_name Portal

enum PortalColor {
	BLUE,
	GREEN,
	MAGENTA,
	ORANGE,
	PURPLE,
}

const BLUE_SPRITE: Texture2D = preload("uid://dsd216451fj65")
const GREEN_SPRITE: Texture2D = preload("uid://eyr5tb3ue13w")
const MAGENTA_SPRITE: Texture2D = preload("uid://bnog4qkjjfdsh")
const ORANGE_SPRITE: Texture2D = preload("uid://c03tp8ghifs3q")
const PURPLE_SPRITE: Texture2D = preload("uid://5ii31bwcp0dx")

@onready var portal_sprite: Sprite2D = $PortalSprite

@export var portal_color: PortalColor = PortalColor.BLUE
@export var target_portal: Portal

var teleport_pop_scale: float = 1.25
var teleport_pop_time: float = 0.06
var teleport_settle_time: float = 0.12

const ROTATION_RANGE: float = 35.0


var teleport_tween: Tween

var checking_for_player_landing: bool = false
var can_teleport: bool = true

var player_reference: Player = null

func _ready() -> void:
	set_color(portal_color)

func _process(_delta: float) -> void:
	if not checking_for_player_landing:
		return
	
	if player_reference:
		if abs(player_reference.player_sprite.position.y - player_reference.sprite_ground_y) < 0.2 and can_teleport:
			can_teleport = false
			checking_for_player_landing = false
			teleport(player_reference, target_portal)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	if can_teleport:
		player_reference = body
		checking_for_player_landing = true


func teleport(player: Player, portal: Portal) -> void:
	target_portal.can_teleport = false
	player.global_position = portal.global_position
	
	play_portal_pop()
	portal.play_portal_pop()

func play_portal_pop() -> void:
	if teleport_tween:
		teleport_tween.kill()
	
	portal_sprite.scale = Vector2.ONE
	portal_sprite.rotation_degrees = 0.0

	var squish_x := randf_range(0.75, 1.45)
	var squish_y := randf_range(0.75, 1.45)

	# Make sure it usually looks stretched, not just randomly small.
	if abs(squish_x - squish_y) < 0.25:
		squish_y = 1.0 / squish_x

	var random_rotation := randf_range(-ROTATION_RANGE, ROTATION_RANGE)

	teleport_tween = create_tween()
	teleport_tween.set_parallel(true)

	# Chaotic hit frame
	teleport_tween.tween_property(
		portal_sprite,
		"scale",
		Vector2(squish_x, squish_y),
		teleport_pop_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	teleport_tween.tween_property(
		portal_sprite,
		"rotation_degrees",
		random_rotation,
		teleport_pop_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	teleport_tween.chain()

	# Overcorrect slightly in the opposite direction
	teleport_tween.tween_property(
		portal_sprite,
		"scale",
		Vector2(1.12, 0.88),
		teleport_settle_time * 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	teleport_tween.tween_property(
		portal_sprite,
		"rotation_degrees",
		-random_rotation * 0.35,
		teleport_settle_time * 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	teleport_tween.chain()

	# Settle
	teleport_tween.tween_property(
		portal_sprite,
		"scale",
		Vector2.ONE,
		teleport_settle_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	teleport_tween.tween_property(
		portal_sprite,
		"rotation_degrees",
		0.0,
		teleport_settle_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_color(new_color: PortalColor) -> void:
	match new_color:
		PortalColor.BLUE:
			portal_sprite.texture = BLUE_SPRITE
		PortalColor.GREEN:
			portal_sprite.texture = GREEN_SPRITE
		PortalColor.MAGENTA:
			portal_sprite.texture = MAGENTA_SPRITE
		PortalColor.ORANGE:
			portal_sprite.texture = ORANGE_SPRITE
		PortalColor.PURPLE:
			portal_sprite.texture = PURPLE_SPRITE

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_reference = null
		can_teleport = true
