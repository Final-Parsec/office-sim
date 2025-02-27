extends Node

var net_worth
var current_time

@export var furniture_scene: PackedScene
@export var furniture_container: Node2D
@export var employee_scene: PackedScene
@export var employee_container: Node2D
@export var widget_scene: PackedScene

func game_over() -> void:
	$ScoreTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	net_worth = 1000
	current_time = 6 * 60
	$Player.start($StartPosition.position)
	$DayTimer.start()
	$HUD.update_net_worth(net_worth)
	$HUD.update_time(current_time)
	$HUD.show_message("Rise & Grind")
	#$Music.play()

func _on_player_furniture_placed() -> void:
	net_worth -= 100
	$HUD.update_net_worth(net_worth)

func _on_player_furniture_placement_requested(position: Vector2) -> void:
	var FURNITURE_COST = 100
	if net_worth >= FURNITURE_COST:
		net_worth -= FURNITURE_COST
		$HUD.update_net_worth(net_worth)
		var furniture = furniture_scene.instantiate()
		furniture.position = position
		print(furniture_container.scale)
		
		furniture_container.add_child(furniture)

func _on_day_timer_timeout() -> void:
	current_time += 5
	if current_time >= 24 * 60:
		current_time = 0
	$HUD.update_time(current_time)
	
	if current_time % 60 == 0:
		$Mailman.summon()
		
	for employee in employee_container.get_children():
		employee.act(current_time)

func _on_mailman_package_collected() -> void:
	net_worth += 10
	$HUD.update_net_worth(net_worth)


func _on_hud_employee_recruited() -> void:
	var employee = employee_scene.instantiate()
	employee.position = $StartPosition.position
	employee_container.add_child(employee)
	employee.money_owed_updated.connect(_on_employee_money_owed_updated)
	employee.widget_action_requested.connect(_on_player_widget_action_requested)


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
	if clicked_widget != null:
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
