extends CharacterBody2D

signal money_owed_updated(money_owed, identity)
signal widget_action_requested(position: Vector2, actor_position: Vector2)
signal package_widget_requested(position: Vector2, actor_position: Vector2)
signal obstacle_added(obstacle_id :int, obstructed_area: Polygon2D)
signal obstacle_removed(obstacle_id: int)

var schedule_start = 7 * 60
var schedule_end = 16 * 60
var money_owed = 0.0
var hourly_rate = 5.0
var movement_speed := 7000.0
var walking_to_work_area := false
var walking_to_commute_tile := false
var movement_delta: float
var carrying_package := false
var identity
var is_navigation_obstacle := true

var last_position: Vector2
var stuck_timer: float = 0.0
var stuck_threshold_time := 1.0 # seconds
var movement_threshold := 5.0 # pixels

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.debug_enabled = true
	$AnimatedSprite2D.animation = "walk"
	last_position = global_position

func act(current_time: int) -> void:
	var on_the_clock = current_time > schedule_start && current_time < schedule_end
	if on_the_clock || carrying_package:
		# Base conditions. On the map and drawing a paycheck.
		visible = true
		$CollisionShape2D.disabled = false
		money_owed += hourly_rate * (5.0 / 60.0)
		money_owed_updated.emit(money_owed, identity)
		
		if carrying_package:
			if navigation_agent.is_navigation_finished():
				var shipping_drop = $"../../EmployeeShippingDrop".global_position
				if global_position.distance_to(shipping_drop) < 50:
					$"../../PackageContainer".create_package(navigation_agent.target_position)
					carrying_package = false
				else:
					set_shipping_drop_destination()
					return
			else:
				return

		# Try to get to specified work area.
		var work_area = $"../../EmployeeWorkArea".global_position
		#print(str(identity) + ': distance to work area ' + str(global_position.distance_to(work_area)))
		if global_position.distance_to(work_area) > 100:
			if walking_to_work_area:
				if !$NavigationAgent2D.is_target_reachable():
					print(str(identity) + ': not reachable')
					walking_to_work_area = false
			else:
				var angle = randf_range(0, TAU)
				var distance = randf_range(0, 100)
				work_area = work_area + Vector2(cos(angle), sin(angle)) * distance
				
				# Prefer workbench
				for furniture in $"../../FurnitureContainer".get_children():
					if work_area.distance_to(furniture.global_position) < 100:
						work_area = furniture.global_position + Vector2(-50, 0)
				
				print(str(identity) + ': setting work area target')
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
	money_owed_updated.emit(money_owed, identity)
	
func _physics_process(delta: float) -> void:
	if !walking_to_work_area && !walking_to_commute_tile && !carrying_package:
		return
	
	if navigation_agent.is_navigation_finished():
		print(str(identity) + ": navigation finished")
		walking_to_work_area = false
		walking_to_commute_tile = false
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed * delta
	$NavigationAgent2D.set_velocity(velocity)
	stuck_timer += delta

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if !walking_to_work_area && !walking_to_commute_tile && !carrying_package:
		return
		
	velocity = safe_velocity
	move_and_slide()
	
	if global_position.distance_to(last_position) < movement_threshold:
		if stuck_timer >= stuck_threshold_time:
			print(str(identity) + ": is stuck! Target reachable is " + str($NavigationAgent2D.is_target_reachable()))
			
			#$NavigationAgent2D.target_position = global_position
			var angle = randf_range(0, TAU)
			var distance = randf_range(0, 1)
			global_position = global_position + Vector2(cos(angle), sin(angle)) * 5
			# handle the stuck case
	else:
		stuck_timer = 0.0
		last_position = global_position

func _process(_delta: float) -> void:
	var has_walking_intent = walking_to_work_area || walking_to_commute_tile || carrying_package
	var is_navigating = !navigation_agent.is_navigation_finished()
	if has_walking_intent && is_navigating:
		$AnimatedSprite2D.play()
		set_and_signal_obstacle_state(false)
	else:
		$AnimatedSprite2D.stop()
		set_and_signal_obstacle_state(true)
		return
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "carry" if carrying_package else "walk" 
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "carry" if carrying_package else "up"
		$AnimatedSprite2D.flip_h = false
		
func set_and_signal_obstacle_state(desired_obstacle_state: bool) -> void:
	if is_navigation_obstacle == desired_obstacle_state:
		return
		
	if is_navigation_obstacle && !desired_obstacle_state:
		is_navigation_obstacle = false
		obstacle_removed.emit(get_instance_id())
		
	if !is_navigation_obstacle && desired_obstacle_state:
		is_navigation_obstacle = true
		var collision_shape = $CollisionShape2D
		var rect_shape = collision_shape.shape.get_rect()
		var navigation_outline = Polygon2D.new()
		navigation_outline.polygon = [
			rect_shape.position,
			rect_shape.position + Vector2(rect_shape.size.x, 0),
			rect_shape.position + Vector2(0, rect_shape.size.y),
			rect_shape.end
		]
		navigation_outline.global_position = collision_shape.global_position
		obstacle_added.emit(get_instance_id(), navigation_outline)
		
func set_shipping_drop_destination() -> void:
	var shipping_drop = $"../../EmployeeShippingDrop".global_position			
	shipping_drop = Vector2(shipping_drop.x + randi_range(-50, 50), shipping_drop.y + randi_range(-50, 50))
	if global_position.distance_to(shipping_drop) > 50:
		$NavigationAgent2D.target_position = shipping_drop
