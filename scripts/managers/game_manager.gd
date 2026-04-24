extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_container: Node2D = $LevelContainer
@onready var transition: CanvasLayer = $Transition
@onready var level_title_label: RichTextLabel = $Transition/LevelTitleLabel

const TRANSITION_LENGTH : float = 1.25

@export var levels: Array[LevelData]
var current_level_index : int = 0
var current_level_id : String
var level_controller_reference: LevelController

func _ready() -> void:
	await start_run()
	

func start_run() -> void:
	load_level(current_level_index)
	animation_player.play("global_transition_in")
	await animation_player.animation_finished
	
	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	await transition_in()
	level_controller_reference.level_id = current_level_id
	level_controller_reference.enter_intro_state()

func transition_in() -> void:
	transition.visible = true
	animation_player.play("transition_in")
	await animation_player.animation_finished
	transition.visible = false

func transition_out() -> void:
	transition.visible = true
	animation_player.play("transition_out")
	await animation_player.animation_finished

func get_level_controller_reference() -> void:
	if level_container.get_child_count() == 0:
		return

	var loaded_level = level_container.get_child(0)
	level_controller_reference = loaded_level.get_tree().get_first_node_in_group("level_controller")

	if level_controller_reference and not level_controller_reference.load_next_level.is_connected(load_next_level):
		level_controller_reference.load_next_level.connect(load_next_level)
	

func get_level_data(level_index: int) -> LevelData:
	if level_index < 0 or level_index >= levels.size():
		return null
	return levels[level_index]

func load_level(level_index: int) -> void:
	var level_data: LevelData = get_level_data(level_index)
	if level_data == null or level_data.level_scene == null:
		push_error("Missing LevelData or level_scene at index %d" % level_index)
		return
	
	current_level_id = level_data.level_id
	
	level_title_label.text = level_data.level_title
	
	var new_level = level_data.level_scene.instantiate()
	level_container.add_child(new_level)
	
	get_level_controller_reference()

func load_next_level() -> void:
	if current_level_index + 1 >= levels.size():
		print("No more levels.")
		return
	
	var upcoming_level_data: LevelData = levels[current_level_index + 1]
	level_title_label.text = upcoming_level_data.level_title
	
	await transition_out()
	await unload_current_level()
	
	current_level_index += 1
	load_level(current_level_index)
	
	await get_tree().create_timer(TRANSITION_LENGTH).timeout
	await transition_in()
	
	if level_controller_reference:
		level_controller_reference.enter_intro_state()
		level_controller_reference.level_id = current_level_id

func unload_current_level() -> void:
	if level_container.get_child_count() == 0:
		return

	var current_level = level_container.get_child(0)
	current_level.queue_free()
	await get_tree().process_frame
	level_controller_reference = null
