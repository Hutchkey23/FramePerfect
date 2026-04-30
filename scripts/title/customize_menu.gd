extends Control
class_name CustomizeMenu

signal exit_customize_menu

@onready var player_panel: PanelContainer = $VBoxContainer/HBoxContainer/PlayerPanel
@onready var player_left_navigation_arrow: Button = $VBoxContainer/HBoxContainer/PlayerPanel/VBoxContainer/NavigationContainer/PlayerLeftNavigationArrow
@onready var player_skin_label: Label = $VBoxContainer/HBoxContainer/PlayerPanel/VBoxContainer/NavigationContainer/PlayerSkinLabel
@onready var player_right_navigation_arrow: Button = $VBoxContainer/HBoxContainer/PlayerPanel/VBoxContainer/NavigationContainer/PlayerRightNavigationArrow
@onready var player_preview: TextureRect = $VBoxContainer/HBoxContainer/PlayerPanel/VBoxContainer/MarginContainer2/PlayerPreview

@onready var goal_panel: PanelContainer = $VBoxContainer/HBoxContainer/GoalPanel
@onready var goal_left_navigation_arrow: Button = $VBoxContainer/HBoxContainer/GoalPanel/VBoxContainer/NavigationContainer/GoalLeftNavigationArrow
@onready var goal_skin_label: Label = $VBoxContainer/HBoxContainer/GoalPanel/VBoxContainer/NavigationContainer/GoalSkinLabel
@onready var goal_right_navigation_arrow: Button = $VBoxContainer/HBoxContainer/GoalPanel/VBoxContainer/NavigationContainer/GoalRightNavigationArrow
@onready var goal_preview: TextureRect = $VBoxContainer/HBoxContainer/GoalPanel/VBoxContainer/MarginContainer2/GoalPreview

@onready var message_label: Label = $VBoxContainer/MarginContainer3/PanelContainer/MessageLabel

@onready var confirm_button: CustomMenuButton = $VBoxContainer/MarginContainer2/ConfirmButton

const GENERIC_MESSAGES: Array[String] = [
	"Looking cool, Jester!",
	"I like your style!",
	"You look out of this world!",
	"Now that’s a look!",
	"Fresh delivery energy.",
	"Stylish and speedy!",
	"You came prepared.",
	"That one’s clean!",
	"Sharp choice!",
	"Now we’re talking.",
	"Absolutely sending it.",
	"Speed meets style.",
	"You’re ready to roll.",
	"This one’s got attitude.",
	"Built for speed.",
	"That’s a fast look.",
	"Minimal. Powerful.",
	"Simple, but deadly.",
	"You’ve got good taste.",
	"Elite choice.",
	"Looking unstoppable.",
	"You mean business.",
	"Locked in.",
	"Ready to deliver.",
	"Stamped and ready.",
	"Special delivery vibes.",
	"This one’s got momentum.",
	"Speed demon certified.",
	"Blink and you’ll miss it.",
	"That’s a smooth operator.",
	"You’re cooking now.",
	"This one’s spicy.",
	"Too slick!",
	"Built different.",
	"Peak performance.",
	"That’s a winner.",
	"Can’t go wrong with that.",
	"Top tier pick.",
	"This one’s it.",
	"Send it!"
]

const FOCUSED_PANEL_SCALE := Vector2(1.05, 1.05)
const NORMAL_PANEL_SCALE := Vector2.ONE
const FOCUSED_PANEL_MODULATE := Color(1, 1, 1, 1)
const DIM_PANEL_MODULATE := Color(0.65, 0.65, 0.65, 1)
const NORMAL_PANEL_MODULATE := Color(1, 1, 1, 1)

var focused_panel: PanelContainer = null
var panel_tweens: Dictionary = {}

var player_skin_index: int = 0
var goal_skin_index: int = 0

var player_skins: Array = []
var goal_skins: Array = []

func _ready() -> void:
	call_deferred("setup_panel_pivots")
	
	player_skins = SkinDatabase.get_skins("player")
	goal_skins = SkinDatabase.get_skins("goal")
	
	load_saved_skin_indexes()
	update_player_skin_display()
	update_goal_skin_display()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		exit_customize_menu.emit()
		UIAudioManager.play_ui_cancel_sfx()
		get_viewport().set_input_as_handled()

func load_saved_skin_indexes() -> void:
	var saved_player_skin := SaveManager.get_selected_skin("player")
	var saved_goal_skin := SaveManager.get_selected_skin("goal")
	
	player_skin_index = find_skin_index(player_skins, saved_player_skin)
	goal_skin_index = find_skin_index(goal_skins, saved_goal_skin)


func find_skin_index(skins: Array, skin_id: String) -> int:
	for i in skins.size():
		if skins[i]["id"] == skin_id:
			return i
	
	return 0

func setup_panel_pivots() -> void:
	player_panel.pivot_offset = player_panel.size / 2.0
	goal_panel.pivot_offset = goal_panel.size / 2.0


func _on_player_left_navigation_arrow_pressed() -> void:
	UIAudioManager.play_ui_pip_sfx()
	player_skin_index = wrapi(player_skin_index - 1, 0, player_skins.size())
	update_player_skin_display()


func _on_player_right_navigation_arrow_pressed() -> void:
	UIAudioManager.play_ui_pip_sfx()
	player_skin_index = wrapi(player_skin_index + 1, 0, player_skins.size())
	update_player_skin_display()


func _on_player_left_navigation_arrow_focus_entered() -> void:
	focus_panel(player_panel)


func _on_player_right_navigation_arrow_focus_entered() -> void:
	focus_panel(player_panel)


func _on_goal_left_navigation_arrow_pressed() -> void:
	UIAudioManager.play_ui_pip_sfx()
	goal_skin_index = wrapi(goal_skin_index - 1, 0, goal_skins.size())
	update_goal_skin_display()


func _on_goal_right_navigation_arrow_pressed() -> void:
	UIAudioManager.play_ui_pip_sfx()
	goal_skin_index = wrapi(goal_skin_index + 1, 0, goal_skins.size())
	update_goal_skin_display()


func _on_goal_left_navigation_arrow_focus_entered() -> void:
	focus_panel(goal_panel)


func _on_goal_right_navigation_arrow_focus_entered() -> void:
	focus_panel(goal_panel)


func _on_confirm_button_pressed() -> void:
	var player_skin: Dictionary = player_skins[player_skin_index]
	var goal_skin: Dictionary = goal_skins[goal_skin_index]
	
	if SkinDatabase.is_skin_unlocked(player_skin):
		SaveManager.set_selected_skin("player", player_skin["id"])
	
	if SkinDatabase.is_skin_unlocked(goal_skin):
		SaveManager.set_selected_skin("goal", goal_skin["id"])
	
	release_focus()
	
	exit_customize_menu.emit()


func _on_confirm_button_focus_entered() -> void:
	unfocus_panels()

func focus_panel(panel: PanelContainer) -> void:
	if focused_panel == panel:
		return
	
	focused_panel = panel
	
	if panel == player_panel:
		animate_panel(player_panel, FOCUSED_PANEL_SCALE, FOCUSED_PANEL_MODULATE)
		animate_panel(goal_panel, NORMAL_PANEL_SCALE, DIM_PANEL_MODULATE)
		update_player_skin_display()
	else:
		animate_panel(goal_panel, FOCUSED_PANEL_SCALE, FOCUSED_PANEL_MODULATE)
		animate_panel(player_panel, NORMAL_PANEL_SCALE, DIM_PANEL_MODULATE)
		update_goal_skin_display()


func unfocus_panels() -> void:
	focused_panel = null
	animate_panel(player_panel, NORMAL_PANEL_SCALE, NORMAL_PANEL_MODULATE)
	animate_panel(goal_panel, NORMAL_PANEL_SCALE, NORMAL_PANEL_MODULATE)
	
	message_label.text = GENERIC_MESSAGES.pick_random()

func animate_panel(panel: PanelContainer, target_scale: Vector2, target_modulate: Color) -> void:
	if panel_tweens.has(panel) and panel_tweens[panel]:
		panel_tweens[panel].kill()
	
	panel.pivot_offset = panel.size / 2.0
	
	var tween := create_tween()
	panel_tweens[panel] = tween
	
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", target_scale, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", target_modulate, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func update_player_skin_display() -> void:
	var skin: Dictionary = player_skins[player_skin_index]
	
	player_skin_label.text = skin["display_name"]
	player_preview.texture = skin["texture"]
	update_message_for_skin(skin)


func update_goal_skin_display() -> void:
	var skin: Dictionary = goal_skins[goal_skin_index]
	
	goal_skin_label.text = skin["display_name"]
	goal_preview.texture = skin["texture"]
	update_message_for_skin(skin)


func update_message_for_skin(skin: Dictionary) -> void:
	if SkinDatabase.is_skin_unlocked(skin):
		message_label.text = skin.get("description", "")
	else:
		message_label.text = skin.get("locked_message", "Locked.")


func _on_visibility_changed() -> void:
	if visible:
		confirm_button.update_pivot()
		player_left_navigation_arrow.grab_silent_focus()
