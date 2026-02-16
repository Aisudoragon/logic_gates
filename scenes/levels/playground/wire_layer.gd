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
		var atlas_coords: Vector2i = tiles[tile]
		set_cell(tile, 0, atlas_coords)


func set_wire(tile: Vector2i, direction: int) -> void:
	set_cell(tile, 0, Vector2i(direction, 0))


func create_gate(tiles: Dictionary[Vector2i, Dictionary]) -> void:
	for tile in tiles:
		var source_id: int = tiles[tile]["source_id"]
		var atlas_coords: Vector2i = tiles[tile]["atlas_coords"]
		set_cell(tile, source_id, atlas_coords, 0)


func set_start_gate(grid_position: Vector2i, state: bool) -> void:
	if not get_cell_source_id(grid_position) == 9:
		return
	set_cell(grid_position, 9, Vector2i(0, 0), state)


func load_custom_gate(custom_gate_pins: Vector2i, grid_position: Vector2i) -> void:
	var max_gate_size: int = maxi(custom_gate_pins.x, custom_gate_pins.y)
	for y in max_gate_size:
		var offset := grid_position + Vector2i(0, y)
		if y < custom_gate_pins.x:
			set_cell(offset, 11, Vector2i(0, 1))
		else:
			set_cell(offset, 11, Vector2i(2, 1))
		if y < custom_gate_pins.y:
			set_cell(offset + Vector2i.RIGHT, 11, Vector2i(1, 1))
		else:
			set_cell(offset + Vector2i.RIGHT, 11, Vector2i(3, 1))
	set_cell(grid_position, 11, Vector2i(0, 0))
	set_cell(grid_position + Vector2i.RIGHT, 11, Vector2i(1, 0))
	if custom_gate_pins.x >= custom_gate_pins.y:
		set_cell(grid_position + Vector2i(0, max_gate_size - 1), 11, Vector2i(0, 2))
	else:
		set_cell(grid_position + Vector2i(0, max_gate_size - 1), 11, Vector2i(2, 2))
	if custom_gate_pins.y >= custom_gate_pins.x:
		set_cell(grid_position + Vector2i(0, max_gate_size - 1) + Vector2i.RIGHT, 11, Vector2i(1, 2))
	else:
		set_cell(grid_position + Vector2i(0, max_gate_size - 1) + Vector2i.RIGHT, 11, Vector2i(3, 2))
