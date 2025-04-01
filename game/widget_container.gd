extends Node2D

@export var widget_scene: PackedScene
@export var navigation_region: NavigationRegion2D

func get_widget_at_position(selected_position: Vector2) -> Node2D:
	for widget in get_children():
		var collision_shape = widget.get_node("CollisionShape2D") as CollisionShape2D
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		if selected_position.distance_to(collision_shape.global_position) <= radius:
			return widget
			
	return null
	
func is_buildable_position(selected_position: Vector2) -> bool:
	var clicked_ineligible_placement = false

	for widget in get_children():
		var collision_shape = widget.get_node("CollisionShape2D") as CollisionShape2D
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		if selected_position.distance_to(collision_shape.global_position) <= radius * 2:
			clicked_ineligible_placement = true
			
	for package in $"../PackageContainer".get_children():
		if selected_position.distance_to(package.global_position) <= 50:
			clicked_ineligible_placement = true
			
	return !clicked_ineligible_placement

func create_widget(desired_position: Vector2) -> void:
	var widget = widget_scene.instantiate()
	widget.position = desired_position
	widget.obstacle_added.connect(navigation_region.obstacle_added)
	widget.obstacle_removed.connect(navigation_region.obstacle_removed)
	add_child(widget)
