extends Node2D

@export var furniture_scene: PackedScene
@export var navigation_region: NavigationRegion2D

func create_furniture(desired_position: Vector2) -> void:
	var furniture = furniture_scene.instantiate()
	furniture.position 	= desired_position
	furniture.obstacle_added.connect(navigation_region.obstacle_added)
	furniture.obstacle_removed.connect(navigation_region.obstacle_removed)
	add_child(furniture)

func get_furniture_at_position(selected_position: Vector2) -> Node2D:
	for furniture in get_children():
		var furniture_rect = furniture.get_current_frame_rect()
		var check_rect = Rect2(furniture.to_local(selected_position), Vector2(1, 1))

		if furniture_rect.intersects(check_rect):
			return furniture

	return null
