extends Node

var net_worth
var current_time

@export var furniture_scene: PackedScene
@export var furniture_container: Node2D
@export var mailmain_scene: PackedScene

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
		furniture_container.add_child(furniture)

func _on_day_timer_timeout() -> void:
	current_time += 5
	if current_time >= 24 * 60:
		current_time = 0
	$HUD.update_time(current_time)
	
	if current_time % 60 == 0:
		$Mailman.summon()

func _on_mailman_package_collected() -> void:
	net_worth += 10
	$HUD.update_net_worth(net_worth)
