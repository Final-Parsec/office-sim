extends RigidBody2D

signal obstacle_added(obstacle_id :int, obstructed_area: Polygon2D)
signal obstacle_removed(obstacle_id: int)

var progress := 0

func _ready() -> void:
	$AnimatedSprite2D.play()
	
	var collision_shape = $CollisionShape2D
	var rect_shape = collision_shape.shape.get_rect()
	var navigation_outline = Polygon2D.new()
	navigation_outline.polygon = [
		rect_shape.position,
		rect_shape.position + Vector2(rect_shape.size.x, 0),
		rect_shape.position + Vector2(0, rect_shape.size.y),
		rect_shape.end
	]
	navigation_outline.global_position = collision_shape.global_position
	obstacle_added.emit(get_instance_id(), navigation_outline)
	
func build(additional_progress: int):
	DamageNumbers.display_number(additional_progress, $NumberSpawn.global_position, additional_progress > 10)
	progress += additional_progress
	if progress > 100:
		progress = 100
	$ProgressLabel.text = str(progress) + "%"

func is_packable() -> bool:
	return progress == 100
	
func _notification(what): 
	if what == NOTIFICATION_PREDELETE: 
		obstacle_removed.emit(get_instance_id())
