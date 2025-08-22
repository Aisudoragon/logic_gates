class_name WireLayer extends TileMapLayer


signal toggle_output(grid_position: Vector2i, state: bool)

const order_executes_per_frame := 1500
var paused_queue := false
var _callable_queue: DoubleLinkedListCallable = DoubleLinkedListCallable.new()

var _next_free_id := 0:
	get:
		_next_free_id += 1
		return _next_free_id
var _per_cell_gate_id: Dictionary[Vector2i, int]
var _update_count := 0:
	get:
		_update_count += 1
		return _update_count
var _per_cell_update_count: Dictionary[Vector2i, int]


func _process(_delta: float) -> void:
	if _callable_queue.is_empty() or paused_queue:
		return
	for i in range(order_executes_per_frame):
		if _callable_queue.is_empty():
			return
		var action: Callable = _callable_queue.pop_front()
		if action is Callable:
			action.call()


func one_queue_action() -> void:
	if _callable_queue.is_empty():
		return
	var action: Callable = _callable_queue.pop_front()
	if action is Callable:
		print(action.get_method(), action.get_bound_arguments())
		action.call()


func delete_stuff() -> void:
	var grid_position: Vector2i = local_to_map(get_local_mouse_position())
	if get_cell_source_id(grid_position) >= 2:
		var gate_id: int = _per_cell_gate_id.get(grid_position, -1)
		delete_gate(grid_position, gate_id)
		return
	erase_cell(grid_position)


func change_wire_crossing() -> void:
	var grid_position: Vector2i = local_to_map(get_local_mouse_position())
	if get_cell_source_id(grid_position) == 0 and get_cell_atlas_coords(grid_position).x == 15:
		var crossing_type: int = 1 if get_cell_atlas_coords(grid_position).y == 0 else 0
		set_cell(grid_position, get_cell_source_id(grid_position), Vector2i(15, crossing_type),
				get_cell_alternative_tile(grid_position))


func create_wire(tiles: Dictionary[Vector2i, Vector2i]) -> void:
	for tile in tiles:
		if _per_cell_gate_id.has(tile):
			continue
		var atlas_coords: Vector2i = tiles[tile]
		set_cell(tile, 0, atlas_coords)


func delete_wire() -> void:
	# TODO
	pass


func create_gate(tiles: Dictionary[Vector2i, Dictionary]) -> void:
	for tile in tiles:
		if _per_cell_gate_id.has(tile):
			return
	var new_gate_id: int = _next_free_id
	for tile in tiles:
		var source_id: int = tiles[tile]["source_id"]
		var atlas_coords: Vector2i = tiles[tile]["atlas_coords"]
		set_cell(tile, source_id, atlas_coords, 0)
		_per_cell_gate_id[tile] = new_gate_id


func delete_gate(grid_position: Vector2i, gate_id: int) -> void:
	if not _per_cell_gate_id.has(grid_position):
		return
	_per_cell_gate_id.erase(grid_position)
	erase_cell(grid_position)
	for next_cell in get_surrounding_cells(grid_position):
		if _per_cell_gate_id.get(next_cell, -1) == gate_id:
			_add_to_queue(&"delete_gate", [next_cell, gate_id])


func toggle_start_gate() -> void:
	var grid_mouse_position: Vector2i = local_to_map(get_local_mouse_position())
	if not (
			get_cell_source_id(grid_mouse_position) == 1
			and get_cell_atlas_coords(grid_mouse_position) == Vector2i(0, 0)
	):
		return
	var state: bool = not get_cell_alternative_tile(grid_mouse_position)
	set_cell(grid_mouse_position, 1, Vector2i(0, 0), state)
	_try_logic_transfer(grid_mouse_position + Vector2i.RIGHT, state, _update_count)
	toggle_output.emit(grid_mouse_position + Vector2i.RIGHT, state)


func _try_logic_transfer(grid_position: Vector2i, state: int, update: int) -> void:
	if (
			get_cell_alternative_tile(grid_position) == state
			or get_cell_source_id(grid_position) == -1
			or _per_cell_update_count.get(grid_position, -1) >= update
	):
		return
	_per_cell_update_count[grid_position] = update
	_add_to_queue(&"_logic_propagate", [grid_position, state, update])


func _logic_propagate(grid_position: Vector2i, state: int, update: int) -> void:
	if get_cell_alternative_tile(grid_position) == state:
		return

	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			state)

	var cell_atlas_coords: Vector2i = get_cell_atlas_coords(grid_position)
	if (
			get_cell_source_id(grid_position) >= 2
			and (cell_atlas_coords == Vector2i.ZERO or cell_atlas_coords == Vector2i(0, 2))
	):
		_add_to_queue(&"_gate_update", [grid_position, state])
		return

	var tile_data: TileData = get_cell_tile_data(grid_position)
	if not tile_data:
		return
	var directions: int = tile_data.get_custom_data("connected_directions")

	var directions_dict: Dictionary[int, Vector2i] = {
		EditorMode.Direction.RIGHT: Vector2i.RIGHT,
		EditorMode.Direction.DOWN: Vector2i.DOWN,
		EditorMode.Direction.LEFT: Vector2i.LEFT,
		EditorMode.Direction.UP: Vector2i.UP,
	}

	for direction in directions_dict:
		if not directions & direction:
			continue
		var next_cell: Vector2i = grid_position + directions_dict[direction]
		if get_cell_atlas_coords(next_cell) == Vector2i(15, 1):
			_add_to_queue(&"_cross_through_wire", [next_cell, state, update, directions_dict[direction]])
		else:
			_try_logic_transfer(next_cell, state, update)


func _cross_through_wire(grid_position: Vector2i, state: int, update: int, direction: Vector2i) -> void:
	if _per_cell_update_count.get(grid_position, -1) >= update:
		return
	if get_cell_atlas_coords(grid_position) == Vector2i(15, 1):
		_per_cell_update_count[grid_position] = update
		_add_to_queue(&"_cross_through_wire", [grid_position + direction, state, update, direction])
	else:
		_logic_propagate(grid_position, state, update)


func _gate_update(grid_position: Vector2i, state: int) -> void:
	var tile_data: TileData = get_cell_tile_data(grid_position)
	if not tile_data:
		return

	var other_input_offset: Vector2i = tile_data.get_custom_data("other_input_offset")
	var output_offset: Vector2i = tile_data.get_custom_data("output_offset")
	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			state)

	var input_1: bool = get_cell_alternative_tile(grid_position)
	var input_2: bool = get_cell_alternative_tile(grid_position + other_input_offset)
	var output: bool
	var gate_type: int = get_cell_source_id(grid_position) - 2
	if gate_type == EditorMode.Gate.NOT:
		output = not input_1
	elif gate_type == EditorMode.Gate.AND:
		output = input_1 and input_2
	elif gate_type == EditorMode.Gate.NAND:
		output = not (input_1 and input_2)
	elif gate_type == EditorMode.Gate.OR:
		output = input_1 or input_2
	elif gate_type == EditorMode.Gate.NOR:
		output = not (input_1 or input_2)
	elif gate_type == EditorMode.Gate.XOR:
		output = not (input_1 == input_2)
	elif gate_type == EditorMode.Gate.XNOR:
		output = input_1 == input_2

	_add_to_queue(&"_logic_propagate", [grid_position + output_offset, output, _update_count])


func _add_to_queue(function: StringName, arguments: Array) -> void:
	_callable_queue.push_back(Callable(self, function).bindv(arguments))
