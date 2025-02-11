extends CharacterBody2D

@export var speed = 400
@export var mob_scene: PackedScene
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
	
func _input(event):
	if event.is_action_released("perform_action"):
		# Build Widget Action
		var clicked_a_widget = false
		
		# Determine if you are clicking existing widget.
		for widget in widget_container.get_children():
			print("Evaluating widget: ", widget.position)
			var collision_shape = widget.get_node("CollisionShape2D") as CollisionShape2D
			var circle = collision_shape.shape as CircleShape2D
			var radius = circle.radius
			if event.position.distance_to(collision_shape.global_position) <= radius * 2:
				clicked_a_widget = true
		
		# If not, place a new widget.
		if !clicked_a_widget:
			place_widget(event.position)
	
func place_widget(spawn_location: Vector2):
	var mob = mob_scene.instantiate()
	var direction = Transform2D.IDENTITY.get_rotation() + PI / 2
	mob.position = spawn_location
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	widget_container.add_child(mob)
