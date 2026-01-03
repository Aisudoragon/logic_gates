class_name WireLayer extends TileMapLayer

signal toggle_output(grid_position: Vector2i, state: bool)


func change_wire_crossing() -> void:
	var grid_position: Vector2i = local_to_map(get_local_mouse_position())
	if get_cell_source_id(grid_position) == 0 and get_cell_atlas_coords(grid_position).x == 15:
		var crossing_type: int = 1 if get_cell_atlas_coords(grid_position).y == 0 else 0
		set_cell(grid_position, get_cell_source_id(grid_position), Vector2i(15, crossing_type),
				get_cell_alternative_tile(grid_position))


func create_wire(tiles: Dictionary[Vector2i, Vector2i]) -> void:
	for tile in tiles:
		#if _per_cell_gate_id.has(tile):
			#continue
		var atlas_coords: Vector2i = tiles[tile]
		set_cell(tile, 0, atlas_coords)


func create_gate(tiles: Dictionary[Vector2i, Dictionary]) -> void:
	#for tile in tiles:
		#if _per_cell_gate_id.has(tile):
			#return
	#var new_gate_id: int = _next_free_id
	for tile in tiles:
		var source_id: int = tiles[tile]["source_id"]
		var atlas_coords: Vector2i = tiles[tile]["atlas_coords"]
		set_cell(tile, source_id, atlas_coords, 0)
		#_per_cell_gate_id[tile] = new_gate_id


#func delete_gate(grid_position: Vector2i, gate_id: int) -> void:
	#if not _per_cell_gate_id.has(grid_position):
		#return
	#_per_cell_gate_id.erase(grid_position)
	#erase_cell(grid_position)
	#for next_cell in get_surrounding_cells(grid_position):
		#if _per_cell_gate_id.get(next_cell, -1) == gate_id:
			#_add_to_queue(&"delete_gate", [next_cell, gate_id])


func toggle_start_gate() -> void:
	var grid_mouse_position: Vector2i = local_to_map(get_local_mouse_position())
	if not get_cell_source_id(grid_mouse_position) == 9:
		return
	var state: bool = not get_cell_alternative_tile(grid_mouse_position)
	set_cell(grid_mouse_position, 9, Vector2i(0, 0), state)
	toggle_output.emit(grid_mouse_position, state)
