extends Node2D

@export var coffee_vending_machine_scene: PackedScene
@export var navigation_region: NavigationRegion2D

func create_coffee_vending_machine(desired_position: Vector2) -> void:
	var coffee_vending_machine = coffee_vending_machine_scene.instantiate()
	coffee_vending_machine.position 	= desired_position
	coffee_vending_machine.obstacle_added.connect(navigation_region.obstacle_added)
	coffee_vending_machine.obstacle_removed.connect(navigation_region.obstacle_removed)
	add_child(coffee_vending_machine)
