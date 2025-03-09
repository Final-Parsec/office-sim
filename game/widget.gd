extends RigidBody2D

var progress

func _ready() -> void:
	var widget_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(widget_types[randi() % widget_types.size()])
	progress = 0
	
func build(additional_progress: int):
	DamageNumbers.display_number(additional_progress, $NumberSpawn.global_position, additional_progress > 10)
	progress += additional_progress
	if progress > 100:
		progress = 100
	$ProgressLabel.text = str(progress) + "%"

func is_packable() -> bool:
	return progress == 100
