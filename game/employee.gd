extends CharacterBody2D

signal money_owed_updated(money_owed)
signal widget_action_requested(position: Vector2, actor_position: Vector2)

var schedule_start = 7 * 60
var schedule_end = 16 * 60
var money_owed = 0.0
var hourly_rate = 5.0
var movement_speed := 7000.0
var walking_to_work_area := false
var walking_to_commute_tile := false
var movement_delta: float

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.debug_enabled = true
	$AnimatedSprite2D.animation = "walk"

func act(current_time: int) -> void:
	var on_the_clock = current_time > schedule_start && current_time < schedule_end
	if on_the_clock:
		# Base conditions. On the map and drawing a paycheck.
		visible = true
		$CollisionShape2D.disabled = false
		money_owed += hourly_rate * (5.0 / 60.0)
		money_owed_updated.emit(money_owed)
		
		# Try to get to specified work area.
		var work_area = $"../../EmployeeWorkArea".global_position
		if global_position.distance_to(work_area) > 50:
			walking_to_work_area = true
			$NavigationAgent2D.target_position = work_area
			return
		
		if walking_to_work_area || walking_to_commute_tile:
			return
		
		# Try to build to my right.
		if RandomNumberGenerator.new().randf() > .3:
			$AnimatedSprite2D.flip_h = false
			widget_action_requested.emit(position + Vector2(50,0), position)
	else:
		if visible:
			var employee_exit = $"../../EmployeeExit".global_position
			if global_position.distance_to(employee_exit) > 50:
				walking_to_commute_tile = true
				$NavigationAgent2D.target_position = employee_exit
				return
			else:
				walking_to_commute_tile = false
				visible = false
				$CollisionShape2D.disabled = true

func pay(money_paid) -> void:
	money_owed -= money_paid
	money_owed_updated.emit(money_owed)
	
func _physics_process(delta: float) -> void:
	if !walking_to_work_area && !walking_to_commute_tile:
		return
	
	if navigation_agent.is_navigation_finished():
		print("navigation finished")
		walking_to_work_area = false
		walking_to_commute_tile = false
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed * delta
	$NavigationAgent2D.set_velocity(velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if !walking_to_work_area && !walking_to_commute_tile:
		return
		
	velocity = safe_velocity
	move_and_slide()

func _process(_delta: float) -> void:
	if walking_to_work_area || walking_to_commute_tile:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		return
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_h = false
