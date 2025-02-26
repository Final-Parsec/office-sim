extends Camera2D

@export var player: CharacterBody2D

func _process(delta: float) -> void:
	var target_position = player.global_position
	position = position.lerp(target_position, delta * 2.0)
