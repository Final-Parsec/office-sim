extends Node2D


func get_package_at_position(selected_position: Vector2) -> Node2D:
	for package in get_children():
		if selected_position.distance_to(package.global_position) <= 25:
			return package
			
	return null
