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
		
		#var furniture_rect = Rect2(furniture.global_position, Vector2(65, 60))
		#print(furniture_rect)
		#var furniture_click_poly = furniture.get_node("ClickPoly") as Polygon2D
		#print(selected_position)
		#print(furniture_click_poly.polygon.to_global())
		#if Geometry2D.is_point_in_polygon(selected_position, furniture_click_poly.polygon):
			#print('furniture clicked')
		#var check_rect = Rect2(selected_position, Vector2(1, 1))
		#print(check_rect)
		if furniture_rect.intersects(check_rect):
			print('furniture clicked')
			return furniture
			
	return null
