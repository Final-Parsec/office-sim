extends CanvasLayer

signal start_game

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
	$NetWorthLabel.text = "$" + str(net_worth)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()

func on_widget_button_pressed() -> void:
	GameState.selected_action = Enums.Actions.WIDGET
	
func on_furniture_button_pressed() -> void:
	GameState.selected_action = Enums.Actions.FURNITURE
	
func update_time(time):
	var meridiem_suffix = "AM" if time < 12 * 60 else "PM"
	var hour = time / 60 if time < 12 * 60 else (time / 60 - 12)
	if hour == 0:
		hour = 12
	var display_hour = "%02d" % hour
	var display_minute = "%02d" % (time % 60)
	$TimeLabel.text = display_hour + ":" + display_minute + " " + meridiem_suffix


func _on_pack_button_pressed() -> void:
	GameState.selected_action = Enums.Actions.PACK
