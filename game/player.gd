extends CharacterBody2D

@export var speed = 400
@export var widget_scene: PackedScene
@export var widget_container: Node2D
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	move_and_collide(velocity * delta)
	position = position.clamp(Vector2.ZERO, screen_size)
	
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
			# Build Widget Action
			var clicked_a_widget = false
			var clicked_ineligible_placement = false
			
			# Determine if you are clicking existing widget.
			for widget in widget_container.get_children():
				var collision_shape = widget.get_node("CollisionShape2D") as CollisionShape2D
				var circle = collision_shape.shape as CircleShape2D
				var radius = circle.radius
				if event.position.distance_to(collision_shape.global_position) <= radius && !clicked_a_widget:
					clicked_a_widget = true
					widget.build(10)
				if event.position.distance_to(collision_shape.global_position) <= radius * 2:
					clicked_ineligible_placement = true
			
			# If not, place a new widget.
			if !clicked_ineligible_placement:
				place_widget(event.position)
		if GameState.selected_action == Enums.Actions.FURNITURE:
			place_furniture(event.position)
	
func place_widget(spawn_location: Vector2):
	var widget = widget_scene.instantiate()
	widget.position = spawn_location
	widget_container.add_child(widget)

func place_furniture(spawn_location: Vector2):
	var widget = widget_scene.instantiate()
	widget.position = spawn_location
	widget_container.add_child(widget)
