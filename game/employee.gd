extends CharacterBody2D

signal money_owed_updated(money_owed)
signal widget_action_requested(position: Vector2, actor_position: Vector2)
signal package_widget_requested(position: Vector2, actor_position: Vector2)

var schedule_start = 7 * 60
var schedule_end = 16 * 60
var money_owed = 0.0
var hourly_rate = 5.0
var movement_speed := 7000.0
var walking_to_work_area := false
var walking_to_commute_tile := false
var movement_delta: float
var carrying_package := false

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
	if on_the_clock || carrying_package:
		# Base conditions. On the map and drawing a paycheck.
		visible = true
		$CollisionShape2D.disabled = false
		money_owed += hourly_rate * (5.0 / 60.0)
		money_owed_updated.emit(money_owed)
		
		if carrying_package:
			if navigation_agent.is_navigation_finished():
				var package = $"../../Player".package_scene.instantiate()
				package.position = navigation_agent.target_position
				$"../../PackageContainer".add_child(package)
				carrying_package = false
			else:
				return

		# Try to get to specified work area.
		var work_area = $"../../EmployeeWorkArea".global_position
		if global_position.distance_to(work_area) > 50:
			if walking_to_work_area:
				if !$NavigationAgent2D.is_target_reachable():
					print('not reachable')
					walking_to_work_area = false
			else:
				work_area = Vector2(work_area.x + randi_range(-50, 50), work_area.y + randi_range(-50, 50))
				print('setting work area target')
				$NavigationAgent2D.target_position = work_area
				walking_to_work_area = true
			return
		
		if walking_to_work_area || walking_to_commute_tile:
			return
		
		# Try to build to my right.
		if RandomNumberGenerator.new().randf() > .3:
			$AnimatedSprite2D.flip_h = false
			var build_location = global_position + Vector2(50, 0)
			var package = $"../../PackageContainer".get_package_at_position(build_location)
			if package != null:
				carrying_package = true
				$AnimatedSprite2D.flip_h = false
				package.queue_free()
				var shipping_drop = $"../../EmployeeShippingDrop".global_position			
				shipping_drop = Vector2(shipping_drop.x + randi_range(-50, 50), shipping_drop.y + randi_range(-50, 50))
				if global_position.distance_to(shipping_drop) > 50:
					$NavigationAgent2D.target_position = shipping_drop
					return
			var widget = $"../../WidgetContainer".get_widget_at_position(build_location)
			if widget == null || widget.progress < 100:
				widget_action_requested.emit(position + Vector2(50,0), position)
			if widget != null && widget.progress == 100:
				package_widget_requested.emit(build_location, global_position)	
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
	if !walking_to_work_area && !walking_to_commute_tile && !carrying_package:
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
	if !walking_to_work_area && !walking_to_commute_tile && !carrying_package:
		return
		
	velocity = safe_velocity
	move_and_slide()

func _process(_delta: float) -> void:
	if walking_to_work_area || walking_to_commute_tile || carrying_package:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		return
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "carry" if carrying_package else "walk" 
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "carry" if carrying_package else "up"
		$AnimatedSprite2D.flip_h = false
