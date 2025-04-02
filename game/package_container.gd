extends Node2D

@export var package_scene: PackedScene
@export var navigation_region: NavigationRegion2D

func get_package_at_position(selected_position: Vector2) -> Node2D:
	for package in get_children():
		if selected_position.distance_to(package.global_position) <= 25:
			return package
			
	return null

func create_package(desired_position: Vector2) -> void:
	var package = package_scene.instantiate()
	package.position = desired_position
	package.obstacle_added.connect(navigation_region.obstacle_added)
	package.obstacle_removed.connect(navigation_region.obstacle_removed)
	add_child(package)
