class_name Wires extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer

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
var _wire_crossing_tiles: Dictionary[Vector2i, bool]
var _gate_tiles: Dictionary[Vector2i, GateTile]


func _process(_delta: float) -> void:
	process_queue(_queue_executes_per_frame)


func process_queue(iterations: int) -> void:
	if _callable_queue.is_empty():
		return
	for i in range(iterations):
		if _callable_queue.is_empty():
			return
		var action: Callable = _callable_queue.pop_front()
		if action is Callable:
			action.call()


func _spread_wire_logic(grid_position: Vector2i, state: bool, update_id: int) -> void:
	var this_wire_tile: WireTile = _wire_tiles[grid_position]
	if this_wire_tile.state == state:
		return
	this_wire_tile.state = state
	this_wire_tile.update_id = update_id

	var connected_wires: Array[Vector2i]
	if this_wire_tile.directions & EditorMode.Direction.RIGHT:
		connected_wires.append(grid_position + Vector2i.RIGHT)
	if this_wire_tile.directions & EditorMode.Direction.DOWN:
		connected_wires.append(grid_position + Vector2i.DOWN)
	if this_wire_tile.directions & EditorMode.Direction.LEFT:
		connected_wires.append(grid_position + Vector2i.LEFT)
	if this_wire_tile.directions & EditorMode.Direction.UP:
		connected_wires.append(grid_position + Vector2i.UP)
	for connected_wire in connected_wires:
		var next_tile: WireTile = _wire_tiles.get(connected_wire)
		if not next_tile:
			continue
		if next_tile.update_id >= update_id:
			continue
		if next_tile.directions & 0b1111 and _wire_crossing_tiles.has(connected_wire):
			# TODO create method for passing through crossing wire
			pass
		else:
			_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(connected_wire,
					state, update_id))
	if _gate_tiles.has(grid_position):
		_callable_queue.push_back(Callable(self, &"_get_into_gate").bind(grid_position))


func _get_into_gate(grid_position: Vector2i) -> void:
	var this_gate_tile: GateTile = _gate_tiles[grid_position]
	var inputs: Array[bool]
	for input_coordinates: Vector2i in this_gate_tile.inputs:
		inputs.append(_wire_tiles[input_coordinates].state)

	var output_wires: Array[WireTile]
	var output_coordinates: Array[Vector2i] = this_gate_tile.outputs
	for output_coordinate in output_coordinates:
		output_wires.append(_wire_tiles[output_coordinate])

	var gate_type: EditorMode.Gate = this_gate_tile.gate
	if gate_type == EditorMode.Gate.NOT:
		output_wires[0].state = not inputs[0]
	elif gate_type == EditorMode.Gate.AND:
		output_wires[0].state = inputs[0] and inputs[1]
	elif gate_type == EditorMode.Gate.NAND:
		output_wires[0].state = not (inputs[0] and inputs[1])
	elif gate_type == EditorMode.Gate.OR:
		output_wires[0].state = inputs[0] or inputs[1]
	elif gate_type == EditorMode.Gate.NOR:
		output_wires[0].state = not (inputs[0] or inputs[1])
	elif gate_type == EditorMode.Gate.XOR:
		output_wires[0].state = not (inputs[0] == inputs[1])
	elif gate_type == EditorMode.Gate.XNOR:
		output_wires[0].state = inputs[0] == inputs[1]

	for index in output_wires.size():
		_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(
				output_coordinates[index], output_wires[index].state, _logic_update_id))


func place_wire() -> void:
	var wire_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	if wire_tiles.size() == 1:
		wire_layer.change_wire_crossing()
		highlight_layer.clear_position_buffer()
		return

	var wire_types: Dictionary[Vector2i, Vector2i]
	for tile in wire_tiles:
		wire_types[tile] = highlight_layer.get_cell_atlas_coords(tile)
	wire_layer.create_wire(wire_types)
	highlight_layer.clear_position_buffer()


func place_gate() -> void:
	var gate_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	var gate_data_cells: Dictionary[Vector2i, Dictionary]
	for tile in gate_tiles:
		var cell_source_id: int = highlight_layer.get_cell_source_id(tile)
		var cell_atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(tile)
		gate_data_cells[tile] = {
			"source_id": cell_source_id,
			"atlas_coords": cell_atlas_coords,
		}
	wire_layer.create_gate(gate_data_cells)


class WireTile:

	var state: bool
	var update_id: int
	var directions: int


	func _to_string() -> String:
		return "%s, update %d, directions %d" % [state, update_id, directions]


class GateTile:

	var gate: EditorMode.Gate
	var id: int
	var inputs: Array[Vector2i]
	var outputs: Array[Vector2i]
