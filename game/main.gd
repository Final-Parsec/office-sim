extends Node

var net_worth
var current_time
var drive_points
var player_tile_position
var carry_package
var employee_instances = {}
var current_quest_progress := 0.0

@export var employee_scene: PackedScene
@export var employee_carry_scene: PackedScene
@export var employee_container: Node2D

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
		DamageNumbers.money_number(-100)
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
			DamageNumbers.money_number(-5)
			drive_points += 1
			$HUD.update_drive_points(drive_points)
			DamageNumbers.display_number(1, $Player/NumberSpawn.global_position, true)

func _on_mailman_package_collected() -> void:
	net_worth += 10
	$HUD.update_net_worth(net_worth)
	DamageNumbers.money_number(10)


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
	DamageNumbers.money_number(-employee.money_owed)
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
	DamageNumbers.money_number(-amount_to_pay)

func _on_player_widget_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	var clicked_furniture = $FurnitureContainer.get_furniture_at_position(position)
	if clicked_furniture != null:
		position = clicked_furniture.global_position + Vector2(0, -20)
		
	var clicked_widget = $WidgetContainer.get_widget_at_position(position)
	if clicked_widget != null && clicked_widget.progress < 100:
		var max_build = 15 if drive_points > 0 else 1
		if clicked_furniture:
			max_build += 5
		var progress = randi_range(1, max_build)
		clicked_widget.build(progress)
		if clicked_widget.progress == 100 && current_quest_progress <= 50:
			current_quest_progress = 50
			$HUD.update_quest_progress(current_quest_progress)
		if drive_points > 0:
			drive_points -= 1
		$HUD.update_drive_points(drive_points)

	if $WidgetContainer.is_buildable_position(position):
		$WidgetContainer.create_widget(position)
		if clicked_furniture != null:
			var new_widget = $WidgetContainer.get_widget_at_position(position)
			new_widget.z_index = 1
		if current_quest_progress <= 25:
			current_quest_progress = 25
			$HUD.update_quest_progress(current_quest_progress)
		drive_points -= 5
		$HUD.update_drive_points(drive_points)
		
func _on_employee_widget_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	var clicked_furniture = $FurnitureContainer.get_furniture_at_position(position)
	if clicked_furniture != null:
		position = clicked_furniture.global_position + Vector2(0, -20)
		
	var clicked_widget = $WidgetContainer.get_widget_at_position(position)
	if clicked_widget != null && clicked_widget.progress < 100:
		var max_build = 10
		if clicked_furniture:
			max_build += 5
		var progress = randi_range(1, max_build)
		clicked_widget.build(progress)

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
			if current_quest_progress <= 75:
				current_quest_progress = 75
				$HUD.update_quest_progress(current_quest_progress)
			widget.queue_free()


func _on_player_coffee_vending_machine_placement_requested(position: Vector2) -> void:
	if !$CursorIndicator.visible or $CursorIndicator.animation == 'coffee_vending_machine_invalid':
		return

	var COFFEE_VENDING_MACHINE_COST = 100
	if net_worth >= COFFEE_VENDING_MACHINE_COST:
		net_worth -= COFFEE_VENDING_MACHINE_COST
		$HUD.update_net_worth(net_worth)
		DamageNumbers.money_number(-100)
		
		$CoffeeVendingMachineContainer.create_coffee_vending_machine(position)
		$Player.in_coffee_zone = true


func _on_player_carry_action_requested(position: Vector2, actor_position: Vector2) -> void:
	const CARRY_ACTION_RANGE = 100
	if position.distance_to(actor_position) > CARRY_ACTION_RANGE:
		return
	
	if $Player.carrying_package:
		$PackageContainer.create_package(position)
		if current_quest_progress < 100:
			var dropped_on_shipping_area = false
			var tile_coord = $TileMapLayer.local_to_map($TileMapLayer.to_local(position))
			var tile_data = $TileMapLayer.get_cell_tile_data(tile_coord)
			if tile_data && tile_data.get_custom_data("is_shipping"):
				dropped_on_shipping_area = true
			if dropped_on_shipping_area:
				current_quest_progress = 100
				net_worth += 100
				$HUD.update_net_worth(net_worth)
				DamageNumbers.money_number(100)
				$HUD.update_quest_progress(current_quest_progress)
		$Player.carrying_package = false
	elif $Player.carrying_furniture:
		$FurnitureContainer.create_furniture(position)
		$Player.carrying_furniture = false
	else:
		var furniture = $FurnitureContainer.get_furniture_at_position(position)
		if furniture != null:
			$Player.carrying_furniture = true
			furniture.queue_free()
			return
		
		var package = $PackageContainer.get_package_at_position(position)
		if package != null:
			$Player.carrying_package = true
			package.queue_free()
			return


func _on_hud_employee_work_area_assigned(assigned_employee: Enums.Employees) -> void:
	var employee = employee_instances[assigned_employee]
	employee.assign_work_area($Player.global_position)
	$HUD.show_message("Assigned to player's current position.")
