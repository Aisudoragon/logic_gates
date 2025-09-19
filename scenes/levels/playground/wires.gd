class_name Wires extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer

var _place_wire_checkpoints: Array[Vector2i]

var _queue_executes_per_frame := 1
var _callable_queue := DoubleLinkedListCallable.new()
var _next_free_gate_id := 0:
	get:
		_next_free_gate_id += 1
		return _next_free_gate_id
var _logic_update_id := 0:
	get:
		_logic_update_id += 1
		return _logic_update_id
var _wire_tiles: Dictionary[Vector2i, WireTile]
var _wire_crossing_tiles: Dictionary[Vector2i, WireCrossing]
var _gate_tiles: Dictionary[Vector2i, int]
var _gates: Dictionary[int, GateTile]


func _process(_delta: float) -> void:
	process_queue(_queue_executes_per_frame)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	var event_key := event as InputEventKey
	# TODO Handle keyboard input here
	if event_key.is_action_pressed(&"rotate"):
		print("Tried to rotate")
	elif event_key.is_action_pressed(&"special"):
		print("Tried to special (add checkpoint to wire placing)")
		_add_checkpoint_to_wire()


func _unhandled_input(_event: InputEvent) -> void:
	# TODO Handle input only for itself, if input is handled: mark it as such
	# Maybe input of highlight layer should be handled here?
	pass


func _draw() -> void:
	for grid_position in _wire_tiles:
		var wire_color: Color
		if _wire_tiles[grid_position].state:
			wire_color = Color.GREEN
		else:
			wire_color = Color.RED
		wire_color = Color(wire_color, 0.5)
		draw_rect(Rect2i(grid_position * 64 + Vector2i(8, 8), Vector2i(48, 48)), wire_color)
		draw_string(ThemeDB.fallback_font, grid_position * 64 + Vector2i(2, 14),
				str(_wire_tiles[grid_position].update_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 16,
				Color.BLACK)


func place_wire() -> void:
	var wire_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	if wire_tiles.size() == 1:
		if _wire_tiles.has(wire_tiles[0]) and _wire_tiles[wire_tiles[0]].direction == 15:
			@warning_ignore_start("return_value_discarded")
			_wire_tiles.erase(wire_tiles[0])
			_wire_crossing_tiles[wire_tiles[0]] = WireCrossing.new()
		elif _wire_crossing_tiles.has(wire_tiles[0]):
			_wire_crossing_tiles.erase(wire_tiles[0])
			@warning_ignore_restore("return_value_discarded")
			_wire_tiles[wire_tiles[0]] = WireTile.new(15)

		wire_layer.change_wire_crossing()
		highlight_layer.clear_position_buffer()
		return

	var wire_types: Dictionary[Vector2i, Vector2i]
	for tile in wire_tiles:
		if _gate_tiles.has(tile):
			continue
		wire_types[tile] = highlight_layer.get_cell_atlas_coords(tile)

		var tile_data: TileData = highlight_layer.get_cell_tile_data(tile)
		assert(tile_data, "What, how, huh?")
		var connected_directions: int = tile_data.get_custom_data("connected_directions")
		_wire_tiles[tile] = WireTile.new(connected_directions)
	wire_layer.create_wire(wire_types)
	highlight_layer.clear_position_buffer()


func place_gate() -> void:
	var gate_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	var gate_data_cells: Dictionary[Vector2i, Dictionary]
	for tile in gate_tiles:
		var cell_source_id: int = highlight_layer.get_cell_source_id(tile)
		var cell_atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(tile)
		gate_data_cells[tile] = {"source_id": cell_source_id, "atlas_coords": cell_atlas_coords}

		if _gate_tiles.has(tile):
			return
	# HACK change it later to soomething that supports custom gates
	var new_gate_id: int = _next_free_gate_id
	_gates[new_gate_id] = GateTile.new(highlight_layer.get_cell_source_id(gate_tiles[0]) - 2)
	for tile in gate_tiles:
		_gate_tiles[tile] = new_gate_id
		if (
				highlight_layer.get_cell_atlas_coords(tile) == Vector2i()
				or highlight_layer.get_cell_atlas_coords(tile) == Vector2i(0, 2)
		):
			_wire_tiles[tile] = WireTile.new(4)
			_gates[new_gate_id].inputs.append(tile)
		elif highlight_layer.get_cell_atlas_coords(tile) == Vector2i(2, 1):
			_wire_tiles[tile] = WireTile.new(1)
			_gates[new_gate_id].outputs.append(tile)
	wire_layer.create_gate(gate_data_cells)


func process_queue(iterations: int) -> void:
	if _callable_queue.is_empty():
		#queue_redraw()
		return
	for i in range(iterations):
		if _callable_queue.is_empty():
			return
		var action: Callable = _callable_queue.pop_front()
		if action is Callable:
			action.call()


func _add_checkpoint_to_wire() -> void:
	if _place_wire_checkpoints.is_empty():
		return
	var mouse_position_on_grid: Vector2i = get_local_mouse_position() / 64
	_place_wire_checkpoints.append(mouse_position_on_grid)


func _spread_wire_logic(grid_position: Vector2i, state: bool, update_id: int) -> void:
	var this_wire_tile: WireTile = _wire_tiles[grid_position]
	if this_wire_tile.state == state:
		return
	this_wire_tile.state = state
	this_wire_tile.update_id = update_id

	var directions_dict: Dictionary[int, Vector2i] = {
		EditorMode.Direction.RIGHT: Vector2i.RIGHT,
		EditorMode.Direction.DOWN: Vector2i.DOWN,
		EditorMode.Direction.LEFT: Vector2i.LEFT,
		EditorMode.Direction.UP: Vector2i.UP,
	}
	for direction in directions_dict:
		if not this_wire_tile.direction & direction:
			continue
		var next_tile_position: Vector2i = grid_position + directions_dict[direction]
		if _wire_tiles.has(next_tile_position):
			if _wire_tiles[next_tile_position].update_id >= update_id:
				continue
			_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(next_tile_position,
					state, update_id))
		elif _wire_crossing_tiles.has(next_tile_position):
			if _wire_crossing_tiles[next_tile_position].get_axis_wire(
					directions_dict[direction]).update_id >= update_id:
				continue
			_callable_queue.push_back(Callable(self, &"_spread_wire_through_crossing").bind(
					next_tile_position, state, update_id, directions_dict[direction]))
		else:
			push_error("%d direction is set but nothing is in %s" % [direction, next_tile_position])

	if _gate_tiles.has(grid_position):
		for output: Vector2i in _gates[_gate_tiles[grid_position]].outputs:
			if grid_position == output:
				return
		_callable_queue.push_back(Callable(self, &"_get_into_gate").bind(grid_position))


func _spread_wire_through_crossing(grid_position: Vector2i, state: bool, update_id: int,
		direction: Vector2i) -> void:
	var this_wire: WireTile = _wire_crossing_tiles[grid_position].get_axis_wire(direction)
	if this_wire.state == state:
		return
	this_wire.state = state
	this_wire.update_id = update_id

	var next_tile_position: Vector2i = grid_position + direction
	if _wire_crossing_tiles.has(next_tile_position):
		_callable_queue.push_back(Callable(self, &"_spread_wire_through_crossing").bind(
				next_tile_position, state, update_id, direction))
		return
	_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(next_tile_position,
					state, update_id))


func _get_into_gate(grid_position: Vector2i) -> void:
	var this_gate_tile: GateTile = _gates[_gate_tiles[grid_position]]
	var inputs: Array[bool]
	for input_coordinates: Vector2i in this_gate_tile.inputs:
		inputs.append(_wire_tiles[input_coordinates].state)

	var output_coordinates: Array[Vector2i] = this_gate_tile.outputs
	var outputs: Array[bool]
	var error: int = outputs.resize(output_coordinates.size())
	if error:
		printerr("Resizing array failed. How?")

	var gate_type: EditorMode.Gate = this_gate_tile.gate
	if gate_type == EditorMode.Gate.NOT:
		outputs[0] = not inputs[0]
	elif gate_type == EditorMode.Gate.AND:
		outputs[0] = inputs[0] and inputs[1]
	elif gate_type == EditorMode.Gate.NAND:
		outputs[0] = not (inputs[0] and inputs[1])
	elif gate_type == EditorMode.Gate.OR:
		outputs[0] = inputs[0] or inputs[1]
	elif gate_type == EditorMode.Gate.NOR:
		outputs[0] = not (inputs[0] or inputs[1])
	elif gate_type == EditorMode.Gate.XOR:
		outputs[0] = not (inputs[0] == inputs[1])
	elif gate_type == EditorMode.Gate.XNOR:
		outputs[0] = inputs[0] == inputs[1]

	for index in outputs.size():
		_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(
				output_coordinates[index], outputs[index], _logic_update_id))


func _on_wire_layer_toggle_output(grid_position: Vector2i, state: bool) -> void:
	_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(grid_position, state,
			_logic_update_id))


func _on_file_dialog_file_selected(path: String) -> void:
	var new_save: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	var placement_dict: Dictionary[Vector2i, Dictionary]
	var success: bool
	for tile in _wire_tiles:
		success = placement_dict.set(tile,{"wires": _wire_tiles[tile].to_dict()})
		if not success:
			printerr("Couldn't write wire tile into dictionary at " + str(tile))
	for tile in _wire_crossing_tiles:
		success = placement_dict.set(tile, {"wires": _wire_crossing_tiles[tile].to_dict()})
		if not success:
			printerr("Couldn't write wire crossing tile into dictionary at " + str(tile))
	for tile in _gate_tiles:
		if placement_dict.has(tile):
			placement_dict[tile].get_or_add("gate", _gate_tiles[tile])
		else:
			success = placement_dict.set(tile, {"gate": _gate_tiles[tile]})
			if not success:
				printerr("Couldn't write gate into dictionary at " + str(tile))
	var gates_dict: Dictionary[int, Dictionary]
	for gate in _gates:
		gates_dict[gate] = _gates[gate].to_dict()

	var save_dict := {
		"placement": placement_dict,
		"gates": gates_dict
	}

	var saved: bool = new_save.store_string(JSON.stringify(save_dict, "\t"))
	if not saved:
		printerr("Couldn't save file: " + path)


class WireTile:

	var state: bool
	var update_id: int
	var direction: int


	func _init(new_directions: int) -> void:
		direction = new_directions


	func _to_string() -> String:
		return "%s, update %d, directions %d" % [state, update_id, direction]


	func to_dict() -> Dictionary:
		return {"state": state, "direction": direction}


class WireCrossing:

	var horizontal_wire: WireTile
	var vertical_wire: WireTile


	func _init() -> void:
		horizontal_wire = WireTile.new(5)
		vertical_wire = WireTile.new(10)


	func get_axis_wire(direction: Vector2i) -> WireTile:
		if direction.abs().max_axis_index() == Vector2i.Axis.AXIS_X:
			return horizontal_wire
		return vertical_wire


	func to_dict() -> Dictionary:
		var return_dict := {
			"horizontal_wire": horizontal_wire.to_dict(),
			"vertical_wire": vertical_wire.to_dict()
		}
		return return_dict


class GateTile:

	var gate: EditorMode.Gate
	var inputs: Array[Vector2i]
	var outputs: Array[Vector2i]


	func _init(new_gate_type: EditorMode.Gate) -> void:
		gate = new_gate_type


	func to_dict() -> Dictionary:
		var return_dict := {
			"gate": gate,
			"inputs": inputs,
			"outputs": outputs
		}
		return return_dict
