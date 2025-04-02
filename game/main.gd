extends Node

var net_worth
var current_time
var drive_points
var player_tile_position
var carry_package
var employee_instances = {}

@export var employee_scene: PackedScene
@export var employee_carry_scene: PackedScene
@export var employee_container: Node2D
@export var coffee_vending_machine_scene: PackedScene


func game_over() -> void:
	$ScoreTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	net_worth = 1000
	current_time = 6 * 60
	drive_points = 100	
	$Player.obstacle_added.connect($EmployeeNavigationRegion.obstacle_added)
	$Player.obstacle_removed.connect($EmployeeNavigationRegion.obstacle_removed)
	$Player.start($StartPosition.position)
	$DayTimer.start()
	$HUD.update_net_worth(net_worth)
	$HUD.update_time(current_time)
	$HUD.show_message("Rise & Grind")
	$HUD.update_drive_points(drive_points)

func _on_player_furniture_placement_requested(position: Vector2) -> void:
	if !$CursorIndicator.visible or $CursorIndicator.animation == 'basic_workbench_invalid':
		return

	var FURNITURE_COST = 100
	if net_worth >= FURNITURE_COST:
		net_worth -= FURNITURE_COST
		$HUD.update_net_worth(net_worth)
		$FurnitureContainer.create_furniture(position)

func _on_day_timer_timeout() -> void:
	current_time += 5
	if current_time >= 24 * 60:
		current_time = 0
	$HUD.update_time(current_time)
		
	for employee in employee_container.get_children():
		employee.act(current_time)
		
	$Mailman.act(current_time)
	
	if $Player.in_coffee_zone:
		if drive_points >= 100:
			$HUD.show_message("Max drive!")
		elif net_worth < 5:
			$HUD.show_message("Can't afford coffee.")
		else:
			net_worth -= 5
			$HUD.update_net_worth(net_worth)
			drive_points += 1
			$HUD.update_drive_points(drive_points)
			DamageNumbers.display_number(1, $Player/NumberSpawn.global_position, true)

func _on_mailman_package_collected() -> void:
	net_worth += 10
	$HUD.update_net_worth(net_worth)


func _on_hud_employee_recruited(recruited_employee: Enums.Employees) -> void:
	var scene_to_use = employee_scene
	if recruited_employee == Enums.Employees.CARRY:
		scene_to_use = employee_carry_scene
	var employee = scene_to_use.instantiate()
	var spawn_position = $StartPosition.position
	spawn_position = Vector2(spawn_position.x + randi_range(-20, 20), spawn_position.y + randi_range(-20, 20)) # give it a lil wiggle
	employee.identity = recruited_employee
	employee.position = spawn_position
	employee_container.add_child(employee)
	employee.money_owed_updated.connect(_on_employee_money_owed_updated)
	employee.widget_action_requested.connect(_on_employee_widget_action_requested)
	employee.package_widget_requested.connect(_on_player_package_widget_requested)
	employee.obstacle_added.connect($EmployeeNavigationRegion.obstacle_added)
	employee.obstacle_removed.connect($EmployeeNavigationRegion.obstacle_removed)
	employee_instances[recruited_employee] = employee


func _on_hud_employee_fired(fired_employee: Enums.Employees) -> void:
	var employee = employee_instances[fired_employee]
	net_worth -= employee.money_owed
	$HUD.update_net_worth(net_worth)
	employee.queue_free()

func _on_employee_money_owed_updated(money_owed, employee) -> void:
	if employee == Enums.Employees.COLM:
		$HUD/HRPanel/TabContainer/Employees/Employee/VBoxContainer/RunPayrollButton.text = "Run Payroll ($" + str(snapped(money_owed, 0)) + ")"
	elif employee == Enums.Employees.CARRY:
		$HUD/HRPanel/TabContainer/Employees/EmployeeCarry/VBoxContainer/RunPayrollCarryButton.text = "Run Payroll ($" + str(snapped(money_owed, 0)) + ")"
	else:
		push_error("invalid employee")
	
func _on_hud_employee_run_payroll_pressed(paid_employee: Enums.Employees) -> void:
	var employee = employee_instances[paid_employee]
	var amount_to_pay = employee.money_owed
	net_worth -= amount_to_pay
	employee.pay(amount_to_pay)
	$HUD.update_net_worth(net_worth)

func _on_player_widget_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	var clicked_widget = $WidgetContainer.get_widget_at_position(position)
	if clicked_widget != null && clicked_widget.progress < 100:
		var max_build = 15 if drive_points > 0 else 1
		var progress = randi_range(1, max_build )
		clicked_widget.build(progress)
		drive_points -= 1
		$HUD.update_drive_points(drive_points)

	if $WidgetContainer.is_buildable_position(position):
		$WidgetContainer.create_widget(position)
		drive_points -= 5
		$HUD.update_drive_points(drive_points)
		
func _on_employee_widget_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	var clicked_widget = $WidgetContainer.get_widget_at_position(position)
	if clicked_widget != null && clicked_widget.progress < 100:
		clicked_widget.build(10)

	if $WidgetContainer.is_buildable_position(position):
		$WidgetContainer.create_widget(position)

func _on_hud_action_bar_button_pressed() -> void:
	$Player.action_selected()

func _on_hud_accelerate_time_pressed(irl_seconds_per_5_min: float) -> void:
	$DayTimer.wait_time = irl_seconds_per_5_min

func _on_player_moved(player_global_position: Vector2) -> void:
	var tile_coord = $TileMapLayer.local_to_map($TileMapLayer.to_local(player_global_position))
	if tile_coord != player_tile_position:
		player_tile_position = tile_coord
		var tile_data = $TileMapLayer.get_cell_tile_data(tile_coord)
		if tile_data:
			var is_exit = tile_data.get_custom_data("is_exit")
			if is_exit:
				$HUD.show_commute_panel()
				
	$Player.in_coffee_zone = false
	for coffee_vending_machine in $CoffeeVendingMachineContainer.get_children():
		if player_global_position.distance_to(coffee_vending_machine.global_position) <= 100:
			$Player.in_coffee_zone = true

func _on_hud_overlaying_panel_visibility_changed(overlaying_panel_visible: bool) -> void:
	$Player.prevent_player_movement = overlaying_panel_visible

func _on_hud_player_rest_requested() -> void:
	$DayTimer.paused = true
	while current_time != 6 * 60:
		print('advancing time ' + str(current_time) + ' - ' + str(drive_points))
		_on_day_timer_timeout()
		if drive_points < 100:
			drive_points += 1
			$HUD.update_drive_points(drive_points)
		
	$DayTimer.paused = false


func _on_player_package_widget_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	for widget in $WidgetContainer.get_children():
		var collision_shape = widget.get_node("CollisionShape2D") as CollisionShape2D
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		if position.distance_to(collision_shape.global_position) <= radius && widget.is_packable():
			$PackageContainer.create_package(widget.position)
			widget.queue_free()


func _on_player_coffee_vending_machine_placement_requested(position: Vector2) -> void:
	if !$CursorIndicator.visible or $CursorIndicator.animation == 'coffee_vending_machine_invalid':
		return

	var COFFEE_VENDING_MACHINE_COST = 100
	if net_worth >= COFFEE_VENDING_MACHINE_COST:
		net_worth -= COFFEE_VENDING_MACHINE_COST
		$HUD.update_net_worth(net_worth)
		var coffee_vending_machine = coffee_vending_machine_scene.instantiate()
		coffee_vending_machine.position = position
		coffee_vending_machine.y_sort_enabled = true
		$CoffeeVendingMachineContainer.add_child(coffee_vending_machine)
		$Player.in_coffee_zone = true


func _on_player_carry_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if $Player.carrying_package && position.distance_to(actor_position) < 100:
		$PackageContainer.create_package(position)
		$Player.carrying_package = false
	else:
		var package = $PackageContainer.get_package_at_position(position)
		if package != null && position.distance_to(actor_position) < 100:
			$Player.carrying_package = true
			package.queue_free()
