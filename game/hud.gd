extends CanvasLayer

signal start_game
signal action_bar_button_pressed
signal employee_recruited
signal employee_fired
signal employee_run_payroll_pressed
signal accelerate_time_pressed(irl_seconds_per_5_min: float)
signal overlaying_panel_visibility_changed(overlaying_panel_visible: bool)
signal player_rest_requested

enum AccelerateTimeOptions {
	DEFAULT = 0,
	DOUBLE = 1,
	TRIPLE = 2
}

var current_accelerate_time_option = AccelerateTimeOptions.DEFAULT
var overlaying_panel_visible = false

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge the creeps!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_net_worth(net_worth):
	$NetWorthLabel.text = "$" + str(snapped(net_worth, 0))

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()

func on_widget_button_pressed() -> void:
	set_selected_action(Enums.Actions.WIDGET)
	
func update_time(time):
	if !$AccelerateTimeButton.visible:
		$AccelerateTimeButton.visible = true
		$TopBarBackground.visible = true
	
	var meridiem_suffix = "AM" if time < 12 * 60 else "PM"
	var hour = time / 60 if time < 12 * 60 else (time / 60 - 12)
	if hour == 0:
		hour = 12
	var display_hour = "%02d" % hour
	var display_minute = "%02d" % (time % 60)
	$TimeLabel.text = display_hour + ":" + display_minute + " " + meridiem_suffix

func _on_pack_button_pressed() -> void:
	set_selected_action(Enums.Actions.PACK)

func _on_hr_button_pressed() -> void:
	set_selected_action(Enums.Actions.HR)

func set_selected_action(selected_action: Enums.Actions) -> void:
	for action_bar_button in $ActionBar.get_children():
		action_bar_button.set_default_texture()
		
	match selected_action:
		Enums.Actions.WIDGET:
			$ActionBar/WidgetButton.set_active_texture()
		Enums.Actions.FURNITURE:
			$ActionBar/FurnitureButton.set_active_texture()
		Enums.Actions.PACK:
			$ActionBar/PackButton.set_active_texture()
		Enums.Actions.HR:
			$ActionBar/HRButton.set_active_texture()
	
	GameState.selected_action = selected_action
	action_bar_button_pressed.emit()


func _on_recruit_pressed() -> void:
	$HRPanel/TabContainer/Recruiting/Recruit.visible = false
	$HRPanel/TabContainer/Employees/Employee.visible = true
	employee_recruited.emit()

func _on_fire_button_pressed() -> void:
	$HRPanel/TabContainer/Recruiting/Recruit.visible = true
	$HRPanel/TabContainer/Employees/Employee.visible = false
	employee_fired.emit()


func _on_run_payroll_button_pressed() -> void:
	employee_run_payroll_pressed.emit()


func _on_accelerate_time_pressed() -> void:
	match current_accelerate_time_option:
		AccelerateTimeOptions.DOUBLE:
			$AccelerateTimeButton.text = ">>>"
			current_accelerate_time_option = AccelerateTimeOptions.TRIPLE
			accelerate_time_pressed.emit(1.0)
		AccelerateTimeOptions.TRIPLE:
			$AccelerateTimeButton.text = ">"
			current_accelerate_time_option = AccelerateTimeOptions.DEFAULT
			accelerate_time_pressed.emit(5.0)
		_:
			$AccelerateTimeButton.text = ">>"
			current_accelerate_time_option = AccelerateTimeOptions.DOUBLE
			accelerate_time_pressed.emit(2.5)
			
func _ready() -> void:
	$AccelerateTimeButton.visible = false
	$CommutePanel.visible = false
	$DriveProgressBar.visible = false
	$TopBarBackground.visible = false

func update_drive_points(drive_points) -> void:
	$DriveProgressBar.visible = true
	$DriveProgressBar.value = drive_points

func show_commute_panel() -> void:
	$CommutePanel.visible = true

func _on_close_commute_panel_button_pressed() -> void:
	$CommutePanel.visible = false


func _on_hr_panel_visibility_changed() -> void:
	if overlaying_panel_visible != $HRPanel.visible:
		overlaying_panel_visible = $HRPanel.visible
		overlaying_panel_visibility_changed.emit(overlaying_panel_visible)

func _on_commute_panel_visibility_changed() -> void:
	if overlaying_panel_visible != $CommutePanel.visible:
		overlaying_panel_visible = $CommutePanel.visible
		overlaying_panel_visibility_changed.emit(overlaying_panel_visible)


func _on_rest_button_pressed() -> void:
	player_rest_requested.emit()


func _on_carry_button_pressed() -> void:
	set_selected_action(Enums.Actions.CARRY)


func _on_furniture_button_pressed() -> void:
	set_selected_action(Enums.Actions.FURNITURE)
