extends Panel

func _ready() -> void:
	visible = false

func _on_hud_action_bar_button_pressed() -> void:
	visible = GameState.selected_action == Enums.Actions.HR
