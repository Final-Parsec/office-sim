extends Node2D

@export var furniture_scene: PackedScene
@export var navigation_region: NavigationRegion2D

func create_furniture(desired_position: Vector2) -> void:
	var furniture = furniture_scene.instantiate()
	furniture.position 	= desired_position
	furniture.obstacle_added.connect(navigation_region.obstacle_added)
	furniture.obstacle_removed.connect(navigation_region.obstacle_removed)
	add_child(furniture)
