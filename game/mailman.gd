extends Node2D

var cooldown = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !visible:
		return
		
	cooldown -= delta
	if cooldown <= 0:
		print('claim package')
		cooldown = 1

func summon() -> void:
	visible = true
