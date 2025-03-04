extends AnimatedSprite2D

func _ready() -> void:
	visible = false
	play()
	speed_scale = 0.5
	
func _physics_process(_delta: float) -> void:
	if GameState.selected_action == Enums.Actions.FURNITURE:
		var world_space = get_world_2d().direct_space_state
		var params = PhysicsShapeQueryParameters2D.new()
		params.collide_with_areas = true
		params.collide_with_bodies = true
		params.shape = RectangleShape2D.new()
		params.shape.size = Vector2(65, 60)
		params.transform = Transform2D(0, global_position)
		var collision = world_space.collide_shape(params, 1)
		scale = Vector2(.75, .75)
		if !collision.is_empty():
			animation = "basic_workbench_invalid"
		else:
			animation = "basic_workbench_placement"

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if GameState.selected_action == Enums.Actions.WIDGET:
		scale = Vector2(.5, .5)
		if $"../WidgetContainer".is_buildable_position(global_position):
			animation = "widget_placement"
		else:
			animation = "widget_build"
		
		visible = global_position.distance_to($"../Player".position) <= 100
	elif GameState.selected_action == Enums.Actions.FURNITURE:
		visible = global_position.distance_to($"../Player".position) <= 100
	elif GameState.selected_action == Enums.Actions.CARRY:
		visible = global_position.distance_to($"../Player".position) <= 100
		
		scale = Vector2(.5, .5)
		if $"../Player".carrying_package:
			animation = "carry_package"
		else:
			var package = $"../PackageContainer".get_package_at_position(global_position)
			if package != null:
				animation = "carry_grabbable"
			else:
				animation = "carry"
				
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_hud_action_bar_button_pressed() -> void:
	if GameState.selected_action == Enums.Actions.FURNITURE:
		visible = true
		
	if GameState.selected_action == Enums.Actions.CARRY:
		visible = true
	
	if GameState.selected_action == Enums.Actions.WIDGET:
		visible = true
	else:
		visible = false
