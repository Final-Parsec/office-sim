extends Node

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if is_critical:
		color = "#2B2"
	if value == 0:
		color = "#FFF8"
		
	number.label_settings.font_color = color
	number.label_settings.font_size = 18
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	get_tree().root.call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
	
	
func money_number(value: int):
	if value == 0:
		return
	
	var number = Label.new()
	number.position = Vector2(554, 56)
	var prefix = "-$" if value < 0 else "$"
	number.text = prefix + str(abs(value))
	print(number.text)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#0F0"
	if value < 0:
		color = "#F00"
		
	number.label_settings.font_color = color
	number.label_settings.font_size = 45
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	get_tree().root.get_node("Main").get_node("HUD").call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "scale", Vector2(2, 2), .75
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y + 56, 0.25
	).set_ease(Tween.EASE_OUT).set_delay(.75)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(.75)
	
	await tween.finished
	number.queue_free()
