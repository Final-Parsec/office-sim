extends RigidBody2D

signal obstacle_added(obstacle_id :int, obstructed_area: Polygon2D)
signal obstacle_removed(obstacle_id: int)

func _ready() -> void:
	var collision_shape = $CollisionShape2D
	var rect_shape = collision_shape.shape
	var navigation_outline = Polygon2D.new()
	var extents = (rect_shape.size / 2) + Vector2(20, 20)
	navigation_outline.polygon = [
		Vector2(-extents.x, -extents.y),
		Vector2(extents.x, -extents.y),
		Vector2(extents.x, extents.y),
		Vector2(-extents.x, extents.y)
	]
	navigation_outline.global_position = collision_shape.global_position
	obstacle_added.emit(get_instance_id(), navigation_outline)

func _notification(what): 
	if what == NOTIFICATION_PREDELETE: 
		obstacle_removed.emit(get_instance_id())
