extends Node

var net_worth

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
