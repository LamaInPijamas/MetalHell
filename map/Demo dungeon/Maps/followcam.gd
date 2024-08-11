extends Camera2D

@export var tilemap: TileMap

func _ready():
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.rendering_quadrant_size
	var world_size_pixels = map_rect.size * tile_size
	limit_right = world_size_pixels.x 
	limit_bottom = world_size_pixels.y
	
func _process(delta):
	pass
