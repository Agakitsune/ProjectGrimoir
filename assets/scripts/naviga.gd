extends TileMapLayer

var _wall: TileMapLayer
var _hazard: TileMapLayer

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in _wall.get_used_cells():
		return true
	if coords in _hazard.get_used_cells_by_id(5):
		return true
	return false


func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in _wall.get_used_cells():
		tile_data.set_navigation_polygon(0, null)
	if coords in _hazard.get_used_cells_by_id(5):
		tile_data.set_navigation_polygon(0, null)
