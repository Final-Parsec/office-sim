extends Node2D

func _draw() -> void:
	if GameState.selected_action == Enums.Actions.WIDGET:
		var white : Color = Color.WHITE
		draw_circle(Vector2(0, 0), 100, white, false)
	
