extends Node

var net_worth
var current_time
var drive_points
var player_tile_position
var carry_package

@export var furniture_scene: PackedScene
@export var furniture_container: Node2D
@export var employee_scene: PackedScene
@export var employee_container: Node2D
@export var widget_scene: PackedScene
@export var package_scene: PackedScene
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
		var furniture = furniture_scene.instantiate()
		furniture.position = position
		furniture_container.add_child(furniture)
		var collision_shape = furniture.get_node("FurnitureCollisionShape")
		var rect_shape = collision_shape.shape
		var nav_outline = Polygon2D.new()
		var extents = (rect_shape.size / 2) + Vector2(20, 20)
		nav_outline.polygon = [
			Vector2(-extents.x, -extents.y),
			Vector2(extents.x, -extents.y),
			Vector2(extents.x, extents.y),
			Vector2(-extents.x, extents.y)
		]
		nav_outline.global_position = collision_shape.global_position
		nav_outline.color = Color(1, 0, 0, 0.5)
		print(nav_outline.polygon)
		$NavigationRegion2D.add_child(nav_outline)
		$NavigationRegion2D.bake_navigation_polygon()

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


func _on_hud_employee_recruited() -> void:
	var employee = employee_scene.instantiate()
	employee.position = $StartPosition.position
	employee_container.add_child(employee)
	employee.money_owed_updated.connect(_on_employee_money_owed_updated)
	employee.widget_action_requested.connect(_on_employee_widget_action_requested)


func _on_hud_employee_fired() -> void:
	var employee = employee_container.get_children().front()
	net_worth -= employee.money_owed
	$HUD.update_net_worth(net_worth)
	employee.queue_free()

func _on_employee_money_owed_updated(money_owed) -> void:
	$HUD/HRPanel/TabContainer/Employees/Employee/VBoxContainer/RunPayrollButton.text = "Run Payroll ($" + str(snapped(money_owed, 0)) + ")"
	
func _on_hud_employee_run_payroll_pressed() -> void:
	var employee = employee_container.get_children().front()
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
		place_widget(position)
		drive_points -= 5
		$HUD.update_drive_points(drive_points)
		
func _on_employee_widget_action_requested(position: Vector2, actor_position: Vector2) -> void:
	if position.distance_to(actor_position) > 100:
		return
		
	var clicked_widget = $WidgetContainer.get_widget_at_position(position)
	if clicked_widget != null && clicked_widget.progress < 100:
		clicked_widget.build(10)

	if $WidgetContainer.is_buildable_position(position):
		place_widget(position)


func place_widget(spawn_location: Vector2):
	var widget = widget_scene.instantiate()
	widget.position = spawn_location
	$WidgetContainer.add_child(widget)


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
			var package = package_scene.instantiate()
			package.position = widget.position
			$PackageContainer.add_child(package)
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
