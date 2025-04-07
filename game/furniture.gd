extends RigidBody2D

signal obstacle_added(obstacle_id :int, obstructed_area: Polygon2D)
signal obstacle_removed(obstacle_id: int)

func _ready() -> void:
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

func _notification(what): 
	if what == NOTIFICATION_PREDELETE: 
		obstacle_removed.emit(get_instance_id())

func get_current_frame_rect() -> Rect2:
	var animated_sprite = $AnimatedSprite2D
	var size = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame).get_size()
	var pos = animated_sprite.offset
	if animated_sprite.centered:
		pos -= 0.5 * size
	return Rect2(pos, size)
