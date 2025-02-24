extends AnimatedSprite2D

func _ready() -> void:
	visible = false
	play()
	speed_scale = 0.5

func _process(_delta: float) -> void:
	if GameState.selected_action == Enums.Actions.WIDGET:
		global_position = get_viewport().get_mouse_position()
		visible = global_position.distance_to(get_parent().position) <= 100

func _on_hud_action_bar_button_pressed() -> void:
	if GameState.selected_action == Enums.Actions.WIDGET:
		animation = "widget_placement"
		visible = true
	else:
		visible = false
