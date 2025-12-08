class_name CustomGate extends Node

var _wire_tiles: Dictionary[Vector2i, Wires.WireTile]
var _wire_crossing_tiles: Dictionary[Vector2i, Wires.WireCrossing]
var _gate_tiles: Dictionary[Vector2i, int]
var _gates: Dictionary[int, Wires.GateTile]
var _custom_gate_tiles: Dictionary[Vector2i, Wires.CustomGateTile]
var _parent: Wires

var _callable_queue: DoubleLinkedListCallable


func _init(queue_ref: DoubleLinkedListCallable, parent_ref: Wires) -> void:
	_callable_queue = queue_ref
	_parent = parent_ref


func _spread_wire_logic(grid_position: Vector2i, state: bool, update_id: int) -> void:
	print("Spreading inside gate!")
	var this_wire_tile: Wires.WireTile = _wire_tiles[grid_position]
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
	var this_wire: Wires.WireTile = _wire_crossing_tiles[grid_position].get_axis_wire(direction)
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
	var this_gate_tile: Wires.GateTile = _gates[_gate_tiles[grid_position]]
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
	elif gate_type == EditorMode.Gate.STOP:
		print("TOUCHED OUTPUT")
		# TODO exit into outer gate (if possible)
		var new_coordinate: Vector2i = _custom_gate_tiles[grid_position].swap_coordinate
		_parent._spread_wire_logic(new_coordinate, _wire_tiles[grid_position].state, _parent._logic_update_id)
		
	elif gate_type == EditorMode.Gate.CUSTOM:
		print("Entering custom gate!")
		# TODO Enter into gate coordinates and propagade signal there
		#var the_gate: CustomGate = _custom_gate_tiles[grid_position].inner_workings
		#the_gate._spread_wire_logic(_custom_gate_tiles[grid_position].inner_coordinate, _wire_tiles[grid_position].state, _logic_update_id)
