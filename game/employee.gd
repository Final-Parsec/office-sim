extends RigidBody2D

var schedule_start = 7 * 60
var schedule_end = 16 * 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true

func act(current_time: int) -> void:
	if current_time > schedule_start && current_time < schedule_end:
		visible = true
		$CollisionShape2D.disabled = false
	else:
		visible = false
		$CollisionShape2D.disabled = true
