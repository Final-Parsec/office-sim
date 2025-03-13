extends CharacterBody2D

signal furniture_placement_requested(position: Vector2)
signal package_widget_requested(position: Vector2, actor_position: Vector2)
signal widget_action_requested(position: Vector2)
signal moved(position: Vector2)
signal coffee_vending_machine_placement_requested(position: Vector2)

@export var speed = 375
@export var widget_container: Node2D
@export var package_scene: PackedScene
@export var package_container: Node2D

var screen_size
var prevent_player_movement = false
var carrying_package = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _process(delta: float) -> void:
	if !visible:
		return
		
	if prevent_player_movement:
		$AnimatedSprite2D.stop()
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
		moved.emit(global_position)
	else:
		$AnimatedSprite2D.stop()

	move_and_collide(velocity * delta)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_h = false

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("perform_action"):
		if GameState.selected_action == Enums.Actions.WIDGET:
			widget_action_requested.emit(get_global_mouse_position(), position)
		if GameState.selected_action == Enums.Actions.FURNITURE:
			furniture_placement_requested.emit(get_global_mouse_position())
		if GameState.selected_action == Enums.Actions.PACK:
			package_widget_requested.emit(get_global_mouse_position(), position)
		if GameState.selected_action == Enums.Actions.CARRY:
			var mouse_position = get_global_mouse_position()
			if carrying_package && mouse_position.distance_to(position) < 100:
				var package = package_scene.instantiate()
				package.position = mouse_position
				package_container.add_child(package)
				carrying_package = false
			else:
				var package = package_container.get_package_at_position(mouse_position)
				if package != null && mouse_position.distance_to(position) < 100:
					carrying_package = true
					package.queue_free()
		if GameState.selected_action == Enums.Actions.COFFEE_VENDING_MACHINE:
			coffee_vending_machine_placement_requested.emit(get_global_mouse_position())

func action_selected() -> void:
	$RangeMarker.queue_redraw()
