extends Node2D

func _draw() -> void:
	var show_marker = (GameState.selected_action == Enums.Actions.WIDGET ||
	GameState.selected_action == Enums.Actions.FURNITURE ||
	GameState.selected_action == Enums.Actions.CARRY ||
	GameState.selected_action == Enums.Actions.PACK)
	if show_marker:
		var white : Color = Color.WHITE
		draw_circle(Vector2(0, 0), 100, white, false)
	
