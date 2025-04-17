extends TextureRect


func fade_to_black() -> void:
	show()
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 1, .75).finished
	
func fade_to_trans() -> void:
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 5).finished
	hide()
