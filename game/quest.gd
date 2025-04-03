extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	$Collapsible.visible = toggled_on
	
func give_it_lil_wiggle() -> void:
	var header = $Header
	var header_start_y = $Header.position.y
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		header, "position:y", header_start_y + 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		header, "position:y", header_start_y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)

func _on_wiggle_timer_timeout() -> void:
	var collapsed = !$Collapsible.visible
	var displayed_progress = $Header/ProgressBar.value
	if displayed_progress == 0.0 && collapsed:
		give_it_lil_wiggle()

func update_quest_progress(current_quest_progress: float) -> void:
	$Header/ProgressBar.value = current_quest_progress
