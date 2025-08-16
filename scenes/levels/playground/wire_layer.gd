class_name WireLayer extends TileMapLayer

const order_executes_per_frame := 500
var _logic_queue: Array[Callable]


func _process(_delta: float) -> void:
	if _logic_queue.is_empty():
		return
	for i in range(order_executes_per_frame):
		if _logic_queue.is_empty():
			return
		var action: Callable = _logic_queue.pop_back()
		if action is Callable:
			action.call()


func delete_stuff() -> void:
	erase_cell(local_to_map(get_local_mouse_position()))


func delete_wire() -> void:
	# TODO
	pass


func delete_gate() -> void:
	# TODO
	pass


func toggle_start_gate() -> void:
	var grid_mouse_position: Vector2i = local_to_map(get_local_mouse_position())
	if not (
			get_cell_source_id(grid_mouse_position) == 1
			and get_cell_atlas_coords(grid_mouse_position) == Vector2i(0, 0)
	):
		return
	var state: bool = not get_cell_alternative_tile(grid_mouse_position)
	set_cell(grid_mouse_position, 1, Vector2i(0, 0), state)
	_try_logic_transfer(grid_mouse_position + Vector2i.RIGHT, state)


func _try_logic_transfer(grid_position: Vector2i, state: int) -> void:
	if get_cell_alternative_tile(grid_position) & 0b1 == state:
		return
	var tile_source_id: int = get_cell_source_id(grid_position)
	var tile_atlas_coords: Vector2i = get_cell_atlas_coords(grid_position)
	var next_step: Callable
	if (
			tile_source_id >= 2
			and (tile_atlas_coords == Vector2i(0, 0) or tile_atlas_coords == Vector2i(0, 2))
	):
		next_step = Callable(self, &"_gate_update")
	elif tile_source_id == 0:
		next_step = Callable(self, &"_wire_update")
	next_step = next_step.bind(grid_position, state)
	if next_step.is_valid():
		_logic_queue.append(next_step)
	else:
		print("Nowhere to propagade")


func _wire_update(grid_position: Vector2i, state: int) -> void:
	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			state)

	var tile_data: TileData = get_cell_tile_data(grid_position)
	if not tile_data:
		return
	var directions: int = tile_data.get_custom_data("connected_directions")
	if directions & EditorMode.Direction.RIGHT:
		_try_logic_transfer(grid_position + Vector2i.RIGHT, state)
	if directions & EditorMode.Direction.DOWN:
		_try_logic_transfer(grid_position + Vector2i.DOWN, state)
	if directions & EditorMode.Direction.LEFT:
		_try_logic_transfer(grid_position + Vector2i.LEFT, state)
	if directions & EditorMode.Direction.UP:
		_try_logic_transfer(grid_position + Vector2i.UP, state)


func _gate_update(grid_position: Vector2i, state: int) -> void:
	var tile_data: TileData = get_cell_tile_data(grid_position)
	if not tile_data:
		return

	var other_input_offset: Vector2i = tile_data.get_custom_data("other_input_offset")
	var output_offset: Vector2i = tile_data.get_custom_data("output_offset")
	if is_cell_flipped_h(grid_position):
		other_input_offset.y = -other_input_offset.y
		output_offset.y = -output_offset.y
	if is_cell_flipped_v(grid_position):
		other_input_offset.x = -other_input_offset.x
		output_offset.x = -output_offset.x
	if is_cell_transposed(grid_position):
		other_input_offset = Vector2i(other_input_offset.y, other_input_offset.x)
		output_offset = Vector2i(output_offset.y, output_offset.x)

	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			get_cell_alternative_tile(grid_position) & ~0b1 | state)

	var input_1: bool = get_cell_alternative_tile(grid_position) & 0b1
	var input_2: bool = get_cell_alternative_tile(grid_position + other_input_offset) & 0b1
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

	grid_position = grid_position + output_offset

	if not get_cell_alternative_tile(grid_position) & 0b1 ^ int(output):
		return

	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			get_cell_alternative_tile(grid_position) & ~0b1 | int(output))
	tile_data = get_cell_tile_data(grid_position)
	if not tile_data:
		return
	output_offset = tile_data.get_custom_data("output_offset")
	if is_cell_flipped_h(grid_position):
		output_offset.y = -output_offset.y
	if is_cell_flipped_v(grid_position):
		output_offset.x = -output_offset.x
	if is_cell_transposed(grid_position):
		output_offset = Vector2i(output_offset.y, output_offset.x)

	_try_logic_transfer(grid_position + output_offset, output)
