extends RigidBody2D

var navigation_outline: Polygon2D

func _ready() -> void:
	var navigation_region = $"../../NavigationRegion2D"
	var collision_shape = $CollisionShape2D
	var rect_shape = collision_shape.shape
	navigation_outline = Polygon2D.new()
	var extents = (rect_shape.size / 2) + Vector2(20, 20)
	navigation_outline.polygon = [
		Vector2(-extents.x, -extents.y),
		Vector2(extents.x, -extents.y),
		Vector2(extents.x, extents.y),
		Vector2(-extents.x, extents.y)
	]
	navigation_outline.global_position = collision_shape.global_position
	navigation_region.add_child(navigation_outline)
	navigation_region.bake_navigation_polygon()

func _notification(what): 
	if what == NOTIFICATION_PREDELETE: 
		navigation_outline.queue_free()
