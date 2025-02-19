extends Node2D

signal package_collected()

@export var package_container: Node2D

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
		cooldown = 1
		
		var package_to_collect = package_container.get_children().front()
		if package_to_collect != null:
			package_to_collect.queue_free()
			package_collected.emit()
		else:
			visible = false

func summon() -> void:
	visible = true
