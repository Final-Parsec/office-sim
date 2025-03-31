extends NavigationRegion2D

var ready_for_rebake := true
var obstacle_instances := {}
	
func _process(_delta: float) -> void:
	if ready_for_rebake:
		ready_for_rebake = false
		bake_navigation_polygon()

func obstacle_added(obstacle_id: int, obstructed_area: Polygon2D) -> void:
	print('obstacle added ' + str(obstacle_id))
	add_child(obstructed_area)
	obstacle_instances[obstacle_id] = obstructed_area
	ready_for_rebake = true
	
func obstacle_removed(obstacle_id: int) -> void:
	print('obstacle removed ' + str(obstacle_id))
	var obstacle = obstacle_instances.get(obstacle_id)
	if obstacle != null:
		obstacle_instances.erase(obstacle_id)
		obstacle.queue_free()
		ready_for_rebake = true
