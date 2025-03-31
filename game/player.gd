extends CharacterBody2D

signal furniture_placement_requested(position: Vector2)
signal package_widget_requested(position: Vector2, actor_position: Vector2)
signal widget_action_requested(position: Vector2)
signal moved(position: Vector2)
signal coffee_vending_machine_placement_requested(position: Vector2)
signal carry_action_requested(position: Vector2, actor_position: Vector2)

@export var speed = 375.0
@export var widget_container: Node2D
@export var package_scene: PackedScene
@export var package_container: Node2D

var screen_size
var prevent_player_movement = false
var carrying_package = false
var in_coffee_zone = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	$AnimatedSprite2D.animation = "walk"

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
		$AnimatedSprite2D.speed_scale = 1.0
		moved.emit(global_position)
	elif in_coffee_zone:
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.speed_scale = 0.125
		$AnimatedSprite2D.animation = "drink"
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
		if in_coffee_zone:
			$"../HUD".show_message("Can't perform action on coffee break.")
			return
		
		if GameState.selected_action == Enums.Actions.WIDGET:
			widget_action_requested.emit(get_global_mouse_position(), position)
		if GameState.selected_action == Enums.Actions.FURNITURE:
			furniture_placement_requested.emit(get_global_mouse_position())
		if GameState.selected_action == Enums.Actions.PACK:
			package_widget_requested.emit(get_global_mouse_position(), position)
		if GameState.selected_action == Enums.Actions.CARRY:
			carry_action_requested.emit(get_global_mouse_position(), position)
		if GameState.selected_action == Enums.Actions.COFFEE_VENDING_MACHINE:
			coffee_vending_machine_placement_requested.emit(get_global_mouse_position())

func action_selected() -> void:
	$RangeMarker.queue_redraw()
