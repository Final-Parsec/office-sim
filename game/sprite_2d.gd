extends Sprite2D

var speed = 400
var angular_speed = PI

func _process(delta: float):
	rotation += angular_speed * delta
