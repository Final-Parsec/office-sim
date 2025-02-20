extends Panel

func _ready() -> void:
	visible = false
	$TabContainer/Recruiting.visible = true
	$TabContainer/Employees.visible = false
	$TabContainer/Employees/Employee.visible = false

func _on_hud_action_bar_button_pressed() -> void:
	visible = GameState.selected_action == Enums.Actions.HR
