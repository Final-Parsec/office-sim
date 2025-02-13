extends Node

var net_worth

@export var furniture_scene: PackedScene
@export var furniture_container: Node2D

func game_over() -> void:
	$ScoreTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	net_worth = 1000
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_net_worth(net_worth)
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
