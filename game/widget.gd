extends RigidBody2D

signal obstacle_added(obstacle_id :int, obstructed_area: Polygon2D)
signal obstacle_removed(obstacle_id: int)

var progress

func _ready() -> void:
	$AnimatedSprite2D.play()
	progress = 0
	
func build(additional_progress: int):
	DamageNumbers.display_number(additional_progress, $NumberSpawn.global_position, additional_progress > 10)
	progress += additional_progress
	if progress > 100:
		progress = 100
	$ProgressLabel.text = str(progress) + "%"

func is_packable() -> bool:
	return progress == 100
