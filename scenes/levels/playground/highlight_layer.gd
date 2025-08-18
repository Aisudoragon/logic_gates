class_name HighlightLayer extends TileMapLayer

@export var wire_layer: WireLayer

var _wire_position_buffer: Array[Vector2i]


func add_checkpoint() -> void:
	var grid_mouse_position: Vector2i = _mouse_to_grid()
	if _wire_position_buffer.is_empty():
		_wire_position_buffer.append(grid_mouse_position)
	_wire_position_buffer.append(grid_mouse_position)
	_wire_position_buffer.append(grid_mouse_position)


func wire_highlight() -> void:
	clear()

	_wire_position_buffer[-1] = _mouse_to_grid()
	if _wire_position_buffer[-2].x == _wire_position_buffer[-3].x:
		_wire_position_buffer[-2].y = _wire_position_buffer[-1].y
	else:
		_wire_position_buffer[-2].x = _wire_position_buffer[-1].x

	for index in range(0, _wire_position_buffer.size() - 2, 2):
		var start: Vector2i = _wire_position_buffer[index]
		var middle: Vector2i = _wire_position_buffer[index + 1]
		var end: Vector2i = _wire_position_buffer[index + 2]
		var direction: Vector2i = (middle - start).sign()
		_wire_highlight_line(start, middle, direction)
		direction = (end - middle).sign()
		_wire_highlight_line(middle, end, direction)


func change_direction_line() -> void:
	var start: Vector2i = _wire_position_buffer[-3]
	var end: Vector2i = _wire_position_buffer[-1]
	if start.x == _wire_position_buffer[-2].x:
		_wire_position_buffer[-2] = Vector2i(end.x, start.y)
	else:
		_wire_position_buffer[-2] = Vector2i(start.x, end.y)


func point_highlight() -> void:
	clear()
	set_cell(_mouse_to_grid(), 0, Vector2i(0, 0))


func clear_position_buffer() -> void:
	_wire_position_buffer.clear()


func gate_highlight(gate: EditorMode.Gate) -> void:
	clear()
	if gate == EditorMode.Gate.STARTSTOP:
		set_cell(_mouse_to_grid(), 1, Vector2i(0, 0))
		return

	var gate_pattern: TileMapPattern = tile_set.get_pattern(gate)
	var grid_position: Vector2i = _mouse_to_grid() + Vector2i.LEFT
	if gate > 0:
		grid_position += Vector2i.UP
	set_pattern(grid_position, gate_pattern)


func _wire_highlight_line(from: Vector2i, to: Vector2i, direction: Vector2i) -> void:
	if from.x == to.x and direction.y:
		for buffer_y in range(from.y, to.y + direction.y, direction.y):
			if buffer_y != to.y:
				_update_tile_wire_direction(Vector2i(from.x, buffer_y), Vector2i(0, direction.y))
			if buffer_y != from.y:
				_update_tile_wire_direction(Vector2i(from.x, buffer_y), Vector2i(0, -direction.y))
	elif direction.x:
		for buffer_x in range(from.x, to.x + direction.x, direction.x):
			if buffer_x != to.x:
				_update_tile_wire_direction(Vector2i(buffer_x, from.y), Vector2i(direction.x, 0))
			if buffer_x != from.x:
				_update_tile_wire_direction(Vector2i(buffer_x, from.y), Vector2i(-direction.x, 0))


func _update_tile_wire_direction(grid_position: Vector2i, direction_vector: Vector2i,
		add := true) -> void:
	var tile_data: TileData = wire_layer.get_cell_tile_data(grid_position)
	var directions: int
	if tile_data:
		directions = tile_data.get_custom_data("connected_directions")
	tile_data = get_cell_tile_data(grid_position)
	if tile_data:
		directions |= tile_data.get_custom_data("connected_directions")
	var direction_from_vector := (
			EditorMode.Direction.RIGHT if direction_vector == Vector2i.RIGHT
			else EditorMode.Direction.DOWN if direction_vector == Vector2i.DOWN
			else EditorMode.Direction.LEFT if direction_vector == Vector2i.LEFT
			else EditorMode.Direction.UP if direction_vector == Vector2i.UP
			else 0)
	if add:
		directions |= direction_from_vector
	else:
		directions &= ~directions

		if not directions:
			erase_cell(grid_position)
			return
	set_cell(grid_position, 0, Vector2i(directions, 0))


func _mouse_to_grid() -> Vector2i:
	return local_to_map(get_local_mouse_position())
