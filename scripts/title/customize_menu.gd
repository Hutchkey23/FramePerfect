extends Control
class_name CustomizeMenu

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

var focused_panel: PanelContainer = null
var panel_tweens: Dictionary = {}

const FOCUSED_PANEL_SCALE := Vector2(1.05, 1.05)
const NORMAL_PANEL_SCALE := Vector2.ONE
const FOCUSED_PANEL_MODULATE := Color(1, 1, 1, 1)
const DIM_PANEL_MODULATE := Color(0.65, 0.65, 0.65, 1)
const NORMAL_PANEL_MODULATE := Color(1, 1, 1, 1)


func _ready() -> void:
	call_deferred("setup_panel_pivots")


func setup_panel_pivots() -> void:
	player_panel.pivot_offset = player_panel.size / 2.0
	goal_panel.pivot_offset = goal_panel.size / 2.0


func _on_player_left_navigation_arrow_pressed() -> void:
	pass # Replace with function body.


func _on_player_right_navigation_arrow_pressed() -> void:
	pass # Replace with function body.


func _on_player_left_navigation_arrow_focus_entered() -> void:
	focus_panel(player_panel)


func _on_player_right_navigation_arrow_focus_entered() -> void:
	focus_panel(player_panel)


func _on_goal_left_navigation_arrow_pressed() -> void:
	pass # Replace with function body.


func _on_goal_right_navigation_arrow_pressed() -> void:
	pass # Replace with function body.


func _on_goal_left_navigation_arrow_focus_entered() -> void:
	focus_panel(goal_panel)


func _on_goal_right_navigation_arrow_focus_entered() -> void:
	focus_panel(goal_panel)


func _on_confirm_button_pressed() -> void:
	pass # Replace with function body.


func _on_confirm_button_focus_entered() -> void:
	unfocus_panels()

func focus_panel(panel: PanelContainer) -> void:
	if focused_panel == panel:
		return
	
	focused_panel = panel
	
	if panel == player_panel:
		animate_panel(player_panel, FOCUSED_PANEL_SCALE, FOCUSED_PANEL_MODULATE)
		animate_panel(goal_panel, NORMAL_PANEL_SCALE, DIM_PANEL_MODULATE)
	else:
		animate_panel(goal_panel, FOCUSED_PANEL_SCALE, FOCUSED_PANEL_MODULATE)
		animate_panel(player_panel, NORMAL_PANEL_SCALE, DIM_PANEL_MODULATE)


func unfocus_panels() -> void:
	focused_panel = null
	animate_panel(player_panel, NORMAL_PANEL_SCALE, NORMAL_PANEL_MODULATE)
	animate_panel(goal_panel, NORMAL_PANEL_SCALE, NORMAL_PANEL_MODULATE)

func animate_panel(panel: PanelContainer, target_scale: Vector2, target_modulate: Color) -> void:
	if panel_tweens.has(panel) and panel_tweens[panel]:
		panel_tweens[panel].kill()
	
	panel.pivot_offset = panel.size / 2.0
	
	var tween := create_tween()
	panel_tweens[panel] = tween
	
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", target_scale, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", target_modulate, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
