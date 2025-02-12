extends RigidBody2D

var progress

func _ready() -> void:
	var widget_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(widget_types[randi() % widget_types.size()])
	progress = 0

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func build(additional_progress: int):
	progress += additional_progress
	if progress > 100:
		progress = 100
	$ProgressLabel.text = str(progress) + "%"
