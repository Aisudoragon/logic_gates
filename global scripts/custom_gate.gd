class_name CustomGate extends Node

var _wire_tiles: Dictionary[Vector2i, Wires.WireTile]
var _wire_crossing_tiles: Dictionary[Vector2i, Wires.WireCrossing]
var _gate_tiles: Dictionary[Vector2i, int]
var _gates: Dictionary[int, Wires.GateTile]
var _custom_gates: Array[CustomGate]
var _custom_gate_tiles: Dictionary[Vector2i, Wires.CustomGateTile]
var _top_layer: Wires
var parent: Node
var exits: Dictionary[Vector2i, Vector2i]

var _callable_queue: DoubleLinkedListCallable


func _init(queue_ref: DoubleLinkedListCallable, top_layer_ref: Wires) -> void:
	_callable_queue = queue_ref
	_top_layer = top_layer_ref


func _spread_wire_logic(grid_position: Vector2i, state: bool, update_id: int) -> void:
	if not _wire_tiles.has(grid_position):
		return
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
			if _gate_tiles.has(next_tile_position) and _wire_tiles[next_tile_position].direction == 1 and not _wire_tiles[next_tile_position].state == state:
				_wire_tiles.erase(grid_position)
				return
			_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(next_tile_position,
				state, update_id))
		elif _wire_crossing_tiles.has(next_tile_position):
			if _wire_crossing_tiles[next_tile_position].get_axis_wire(
				directions_dict[direction]).update_id >= update_id:
				continue
			_callable_queue.push_back(Callable(self, &"_spread_wire_through_crossing").bind(
				next_tile_position, state, update_id, directions_dict[direction]))

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
		var exit_coords: Vector2i = exits[grid_position]
		parent._spread_wire_logic(exit_coords, _wire_tiles[grid_position].state, _top_layer._logic_update_id)

	elif gate_type == EditorMode.Gate.CUSTOM:
		# TODO Enter into gate coordinates and propagade signal there
		if not _custom_gate_tiles.has(grid_position):
			print("No _custom_gate_tiles at %s", grid_position)
			return
		var the_gate: CustomGate = _custom_gate_tiles[grid_position].inner_workings
		the_gate._spread_wire_logic(_custom_gate_tiles[grid_position].swap_coordinate, _wire_tiles[grid_position].state, _top_layer._logic_update_id)

	for index in outputs.size():
		_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(
				output_coordinates[index], outputs[index], _top_layer._logic_update_id))


func load_custom_gate_deeper(path: String) -> void:
	path = "%s/%s.circuit" % [Filepaths.custom_gates_directory, path]
	var everything_dictionary: Dictionary = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())

	var placement_dictionary: Dictionary = everything_dictionary["placement"]
	for tile_string: String in placement_dictionary:
		var tile: Vector2i = str_to_var("Vector2i" + tile_string)
		if placement_dictionary[tile_string].has("gate"):
			_gate_tiles[tile] = int(placement_dictionary[tile_string]["gate"])
		if placement_dictionary[tile_string].has("wires"):
			var wire_tile: Dictionary = placement_dictionary[tile_string]["wires"]
			if wire_tile.has("direction"):
				var direction: int = wire_tile["direction"]
				var state: bool = wire_tile["state"]
				var new_wire: Wires.WireTile = Wires.WireTile.new(direction)
				new_wire.state = state
				_wire_tiles[tile] = new_wire

			else:
				var wire_crossing: Wires.WireCrossing = Wires.WireCrossing.new()
				var state: bool = wire_tile["horizontal_wire"]["state"]
				wire_crossing.horizontal_wire.state = state
				state = wire_tile["vertical_wire"]["state"]
				wire_crossing.vertical_wire.state = state
				_wire_crossing_tiles[tile] = wire_crossing

	var gates_dictionary: Dictionary = everything_dictionary["gates"]
	for gate: String in gates_dictionary:
		var gate_id: int = int(gate)
		_top_layer._next_free_gate_id = gate_id
		var gate_type: EditorMode.Gate = gates_dictionary[gate]["gate"]

		var inputs: Array[Vector2i]
		for input: String in gates_dictionary[gate]["inputs"]:
			inputs.append(str_to_var("Vector2i" + input))
		var outputs: Array[Vector2i]
		for output: String in gates_dictionary[gate]["outputs"]:
			outputs.append(str_to_var("Vector2i" + output))

		var new_gate: Wires.GateTile = Wires.GateTile.new(gate_type)
		new_gate.inputs = inputs
		new_gate.outputs = outputs
		_gates[gate_id] = new_gate

		if gate_type == EditorMode.Gate.CUSTOM:
			# TODO Load up custom gate from file

			var gate_path: String = "%s/%s.circuit" % [Filepaths.custom_gates_directory, gates_dictionary[gate]["name"]]

			var _custom_gate_dict: Dictionary = JSON.parse_string(FileAccess.open(gate_path, FileAccess.READ).get_as_text())
			create_custom_gate_from_dict(_custom_gate_dict)

			# search for output gates
			var custom_inputs: Array[Vector2i]
			var custom_outputs: Array[Vector2i]
			for potential_gate: String in _custom_gate_dict["gates"]:
				if _custom_gate_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.START:
					custom_inputs.append(str_to_var("Vector2i" + _custom_gate_dict["gates"][potential_gate]["outputs"][0]))
				elif _custom_gate_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.STOP:
					custom_outputs.append(str_to_var("Vector2i" + _custom_gate_dict["gates"][potential_gate]["inputs"][0]))
			custom_inputs.sort_custom(_top_layer.sort_by_y_first)
			custom_outputs.sort_custom(_top_layer.sort_by_y_first)

			for input_index in range(custom_inputs.size()):
				_custom_gate_tiles[str_to_var("Vector2i" + gates_dictionary[gate]["inputs"][input_index])] = Wires.CustomGateTile.new(gate_path, _custom_gates[-1], custom_inputs[input_index])
			for output_index in range(custom_outputs.size()):
				_custom_gates[-1].exits[custom_outputs[output_index]] = str_to_var("Vector2i" + gates_dictionary[gate]["outputs"][output_index])

			var gate_center_place: Vector2i = str_to_var("Vector2i" + gates_dictionary[gate]["inputs"][0])

			for update_position_string: String in gates_dictionary[gate]["inputs"]:
				var update_position: Vector2i = str_to_var("Vector2i" + update_position_string)
				_callable_queue.push_back(Callable(self, &"_get_into_gate").bind(update_position))

			continue


func create_custom_gate_from_dict(custom_gate_dict: Dictionary) -> void:
	var new_custom_gate := CustomGate.new(_callable_queue, _top_layer)
	new_custom_gate.parent = self
	_custom_gates.append(new_custom_gate)

	var gates_dictionary: Dictionary = custom_gate_dict["gates"]

	var custom_gate_inputs: Array[Vector2i]
	var custom_gate_outputs: Array[Vector2i]
	# Fill data for all gates inside.
	for gate: String in gates_dictionary:
		var gate_type: EditorMode.Gate = gates_dictionary[gate]["gate"]
		var inputs: Array[Vector2i]
		for input: String in gates_dictionary[gate]["inputs"]:
			inputs.append(str_to_var("Vector2i" + input))
		var outputs: Array[Vector2i]
		for output: String in gates_dictionary[gate]["outputs"]:
			outputs.append(str_to_var("Vector2i" + output))

		if gate_type == EditorMode.Gate.START:
			custom_gate_inputs.append(outputs[0])
		elif gate_type == EditorMode.Gate.STOP:
			custom_gate_outputs.append(inputs[0])

		var new_gate: Wires.GateTile = Wires.GateTile.new(gate_type)
		new_gate.inputs = inputs
		new_gate.outputs = outputs
		if gates_dictionary[gate].has("name"):
			new_gate.display_name = gates_dictionary[gate]["name"]
		new_custom_gate._gates[int(gate)] = new_gate

		if gate_type == EditorMode.Gate.CUSTOM:
			var gate_path: String = "%s/%s.circuit" % [Filepaths.custom_gates_directory, gates_dictionary[gate]["name"]]
			var deeper_dict: Dictionary = JSON.parse_string(FileAccess.open(gate_path, FileAccess.READ).get_as_text())
			new_custom_gate.create_custom_gate_from_dict(deeper_dict)

			var custom_inputs: Array[Vector2i]
			var custom_outputs: Array[Vector2i]
			for potential_gate: String in deeper_dict["gates"]:
				if deeper_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.START:
					custom_inputs.append(str_to_var("Vector2i" + deeper_dict["gates"][potential_gate]["outputs"][0]))
				elif deeper_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.STOP:
					custom_outputs.append(str_to_var("Vector2i" + deeper_dict["gates"][potential_gate]["inputs"][0]))
			custom_inputs.sort_custom(_top_layer.sort_by_y_first)
			custom_outputs.sort_custom(_top_layer.sort_by_y_first)

			for input_index in range(inputs.size()):
				new_custom_gate._custom_gate_tiles[inputs[input_index]] = Wires.CustomGateTile.new(gate_path, new_custom_gate._custom_gates[-1], custom_inputs[input_index])
			for output_index in range(outputs.size()):
				new_custom_gate._custom_gates[-1].exits[custom_outputs[output_index]] = outputs[output_index]

	var placement_dictionary: Dictionary = custom_gate_dict["placement"]
	# Place grid inside the gate.
	for tile_string: String in placement_dictionary:
		var tile: Vector2i = str_to_var("Vector2i" + tile_string)
		if placement_dictionary[tile_string].has("gate"):
			new_custom_gate._gate_tiles[tile] = int(placement_dictionary[tile_string]["gate"])
			#new_custom_gate._custom_gate_tiles[Vector2i(11, 5)] = CustomGateTile.new(path, new_custom_gate, Vector2i(1, 1))
		if placement_dictionary[tile_string].has("wires"):
			var wire_tile: Dictionary = placement_dictionary[tile_string]["wires"]
			if wire_tile.has("direction"):
				var direction: int = wire_tile["direction"]
				var state: bool = wire_tile["state"]
				var new_wire: Wires.WireTile = Wires.WireTile.new(direction)
				new_wire.state = state
				new_custom_gate._wire_tiles[tile] = new_wire
			else:
				var wire_crossing: Wires.WireCrossing = Wires.WireCrossing.new()
				var state: bool = wire_tile["horizontal_wire"]["state"]
				wire_crossing.horizontal_wire.state = state
				state = wire_tile["vertical_wire"]["state"]
				wire_crossing.vertical_wire.state = state
				new_custom_gate._wire_crossing_tiles[tile] = wire_crossing


func go_deeper(path: String) -> void:
	path = "%s/%s.circuit" % [Filepaths.custom_gates_directory, path]
	var _custom_gate_dict: Dictionary = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	create_custom_gate_from_dict(_custom_gate_dict)
