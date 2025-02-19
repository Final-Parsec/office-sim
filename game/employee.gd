extends RigidBody2D

var schedule_start = 7 * 60
var schedule_end = 16 * 60
var money_owed = 0.0
var hourly_rate = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true

func act(current_time: int) -> void:
	var on_the_clock = current_time > schedule_start && current_time < schedule_end
	if on_the_clock:
		visible = true
		$CollisionShape2D.disabled = false
		money_owed += hourly_rate * (5.0 / 60.0)
	else:
		visible = false
		$CollisionShape2D.disabled = true
