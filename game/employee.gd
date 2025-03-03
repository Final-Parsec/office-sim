extends RigidBody2D

signal money_owed_updated(money_owed)
signal widget_action_requested(position: Vector2, actor_position: Vector2)

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
		money_owed_updated.emit(money_owed)
		
		if RandomNumberGenerator.new().randf() > .3:
			widget_action_requested.emit(position + Vector2(50,0), position)
	else:
		visible = false
		$CollisionShape2D.disabled = true

func pay(money_paid) -> void:
	money_owed -= money_paid
	money_owed_updated.emit(money_owed)
