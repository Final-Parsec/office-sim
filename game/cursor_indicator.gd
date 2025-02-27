extends AnimatedSprite2D

@export var furniture_collision_shape_scene: PackedScene

var furniture_collision_shape

func _ready() -> void:
	visible = false
	play()
	speed_scale = 0.5
	
func _physics_process(_delta: float) -> void:
	if furniture_collision_shape != null:
		var world_space = get_world_2d().direct_space_state
		var params = PhysicsShapeQueryParameters2D.new()
		params.collide_with_areas = true
		params.collide_with_bodies = true
		params.shape = RectangleShape2D.new()
		params.shape.size = Vector2(64, 64)
		params.transform = Transform2D(0, global_position)
		var collision = world_space.collide_shape(params, 1)
		print(furniture_collision_shape.global_position)
		if !collision.is_empty():
			print('bad placement')
		animation = "basic_workbench_placement"

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if GameState.selected_action == Enums.Actions.WIDGET:
		if $"../WidgetContainer".is_buildable_position(global_position):
			animation = "widget_placement"
		else:
			animation = "widget_build"
		
		visible = global_position.distance_to($"../Player".position) <= 100
	elif GameState.selected_action == Enums.Actions.FURNITURE:
		if furniture_collision_shape == null:
			furniture_collision_shape = furniture_collision_shape_scene.instantiate()
			add_child(furniture_collision_shape)
		visible = global_position.distance_to($"../Player".position) <= 100

func _on_hud_action_bar_button_pressed() -> void:
	if GameState.selected_action == Enums.Actions.FURNITURE:
		visible = true
	elif furniture_collision_shape != null:
			furniture_collision_shape.queue_free()
	
	if GameState.selected_action == Enums.Actions.WIDGET:
		visible = true
	else:
		visible = false
