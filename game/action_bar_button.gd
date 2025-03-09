extends Button

@export var default_texture: CompressedTexture2D
@export var active_texture: CompressedTexture2D

func _ready() -> void:
	$TextureRect.texture = default_texture
	
func set_default_texture() -> void:
	$TextureRect.texture = default_texture
	
func set_active_texture() -> void:
	$TextureRect.texture = active_texture
