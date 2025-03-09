extends Node2D

signal package_collected()

@export var package_container: Node2D

var cooldown = 1.0

var schedule_start = 14 * 60
var schedule_end = 16 * 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func act(current_time: int) -> void:
	var on_the_clock = current_time >= schedule_start && current_time < schedule_end
	var already_collected_today = current_time > schedule_start && visible == false
	
	if !on_the_clock || already_collected_today:
		return
		
	visible = true
	var collectible_package = null
	for package in package_container.get_children():
		if package.is_queued_for_deletion():
			continue
		
		var tile_coord = $"../TileMapLayer".local_to_map($"../TileMapLayer".to_local(package.global_position))
		var tile_data = $"../TileMapLayer".get_cell_tile_data(tile_coord)
		if tile_data:
			var is_shipping = tile_data.get_custom_data("is_shipping")
			if is_shipping:
				collectible_package = package
				break

	if collectible_package != null:
		collectible_package.queue_free()
		package_collected.emit()
	else:
		visible = false
