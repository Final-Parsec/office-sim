extends AnimatedSprite2D

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if GameState.selected_action == Enums.Actions.WIDGET:
		position = get_viewport().get_mouse_position()

func _on_hud_action_bar_button_pressed() -> void:
	if GameState.selected_action == Enums.Actions.WIDGET:
		animation = "widget_placement"
		visible = true
	else:
		visible = false
