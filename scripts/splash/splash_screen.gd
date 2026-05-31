extends Control

@onready var main_transition_layer: CanvasLayer = $MainTransitionLayer
@onready var main_transition: ColorRect = $MainTransitionLayer/MainTransition
@onready var splash_logo: TextureRect = $CanvasLayer/CenterContainer/SplashLogo

const HUTCHKEY_GAMES_LOGO : Texture = preload("res://assets/splash/HutchkeyGamesLogoWhite.png")
const GODOT_LOGO : Texture = preload("res://assets/splash/godot.svg")

var skippable : bool = false
var skipping : bool = false
var fade_tween : Tween = null
var fading_out : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	main_transition_layer.visible = true
	splash_logo.texture = HUTCHKEY_GAMES_LOGO
	run_splash_screen_animation()
	BGMManager.play(BGMManager.SEND_IT)

func _input(event: InputEvent) -> void:
	if skipping or not skippable:
		return
	if event is InputEventKey and event.pressed:
		skip_to_title()
	elif event is InputEventMouseButton and event.pressed:
		skip_to_title()
	elif event is InputEventJoypadButton and event.pressed:
		skip_to_title()

func run_splash_screen_animation() -> void:
	await get_tree().create_timer(0.5).timeout
	await fade_in_screen()
	if skipping: return
	await get_tree().create_timer(1.0).timeout
	skippable = true
	if skipping: return
	await fade_out_screen()
	if skipping: return
	await get_tree().create_timer(1.0).timeout
	if skipping: return
	splash_logo.texture = GODOT_LOGO
	if skipping: return
	await fade_in_screen()
	if skipping: return
	await get_tree().create_timer(1.0).timeout
	if skipping: return
	await fade_out_screen()
	if skipping: return
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func fade_in_screen() -> void:
	fading_out = false
	main_transition_layer.visible = true
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(main_transition, "modulate:a", 0.0, 1.0)
	await fade_tween.finished
	
	main_transition_layer.visible = false

func fade_out_screen() -> void:
	fading_out = true
	main_transition_layer.visible = true
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(main_transition, "modulate:a", 1.0, 1.0)
	await fade_tween.finished

func skip_to_title() -> void:
	if skipping:
		return
	
	skipping = true
	skippable = false
	
	if fading_out:
		await get_tree().create_timer(1.0).timeout
	else:
		await fade_out_screen()
	
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
