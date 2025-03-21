extends CharacterBody2D

signal money_owed_updated(money_owed)
signal widget_action_requested(position: Vector2, actor_position: Vector2)

var schedule_start = 7 * 60
var schedule_end = 16 * 60
var money_owed = 0.0
var hourly_rate = 5.0
var movement_speed := 200.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.debug_enabled = true

func act(current_time: int) -> void:
	var on_the_clock = current_time > schedule_start && current_time < schedule_end
	on_the_clock = true
	if on_the_clock:
		$NavigationAgent2D.target_position = $"../../Player".global_position
		
		visible = true
		$CollisionShape2D.disabled = false
		money_owed += hourly_rate * (5.0 / 60.0)
		money_owed_updated.emit(money_owed)
		
		#if RandomNumberGenerator.new().randf() > .3:
			#widget_action_requested.emit(position + Vector2(50,0), position)
	else:
		visible = false
		$CollisionShape2D.disabled = true

func pay(money_paid) -> void:
	money_owed -= money_paid
	money_owed_updated.emit(money_owed)
	
func _physics_process(_delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	$NavigationAgent2D.set_velocity(velocity)

	


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if $NavigationAgent2D.is_navigation_finished() == false:
		velocity = safe_velocity
		move_and_slide()
