extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	$Collapsible.visible = toggled_on
