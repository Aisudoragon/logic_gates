class_name Wires extends Node2D

const input_list_element: PackedScene = preload("res://scenes/interfaces/input_list_element.tscn")
const output_list_element: PackedScene = preload("res://scenes/interfaces/output_list_element.tscn")

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer

var _place_wire_checkpoints: Array[Vector2i]
var _custom_gate_dict: Dictionary

signal queue_cleared()
signal play_ui_sound()

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
var _custom_gates: Array[CustomGate]
var _custom_gate_tiles: Dictionary[Vector2i, CustomGateTile]

var _custom_gates_names: Dictionary[Vector2i, String]
var _custom_gates_input_pins_names: Dictionary[Vector2i, String]
var _custom_gates_output_pins_names: Dictionary[Vector2i, String]

var is_sandbox: bool = true
var dimension_limits: Array[Vector2i]
var untouchable_tiles: Array[Vector2i]


func _process(_delta: float) -> void:
	process_queue(_queue_executes_per_frame)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	var event_key := event as InputEventKey
	# TODO Handle keyboard input here
	if event_key.is_action_pressed(&"special"):
		_add_checkpoint_to_wire()


func _unhandled_input(_event: InputEvent) -> void:
	# TODO Handle input only for itself, if input is handled: mark it as such
	# Maybe input of highlight layer should be handled here?
	pass


func _draw() -> void:
	var red_lines: PackedVector2Array
	var green_lines: PackedVector2Array
	for grid_position in _wire_tiles:
		if not _gate_tiles.has(grid_position):
			var wire_direction: int = _wire_tiles[grid_position].direction
			var wire_state: bool = _wire_tiles[grid_position].state
			var two_points: PackedVector2Array
			if wire_direction & EditorMode.Direction.RIGHT:
				two_points = [
					grid_position * 64 + Vector2i(32, 32),
					grid_position * 64 + Vector2i(63, 32),
				]
				(green_lines if wire_state else red_lines).append_array(two_points)
			if wire_direction & EditorMode.Direction.DOWN:
				two_points = [
					grid_position * 64 + Vector2i(32, 32),
					grid_position * 64 + Vector2i(32, 63),
				]
				(green_lines if wire_state else red_lines).append_array(two_points)
			if wire_direction & EditorMode.Direction.LEFT:
				two_points = [
					grid_position * 64 + Vector2i(32, 32),
					grid_position * 64 + Vector2i(1, 32),
				]
				(green_lines if wire_state else red_lines).append_array(two_points)
			if wire_direction & EditorMode.Direction.UP:
				two_points = [
					grid_position * 64 + Vector2i(32, 32),
					grid_position * 64 + Vector2i(32, 1),
				]
				(green_lines if wire_state else red_lines).append_array(two_points)
			draw_circle(grid_position * 64 + Vector2i(32, 32), 3.5, Color.GREEN if wire_state else Color.DARK_RED)
			if (
					wire_direction == 7 or wire_direction == 11 or wire_direction == 13
					or wire_direction == 14 or wire_direction == 15
			):
				draw_circle(grid_position * 64 + Vector2i(32, 32), 12, Color.GREEN if wire_state else Color.DARK_RED)
	for grid_position in _wire_crossing_tiles:
		var points: PackedVector2Array = [
			grid_position * 64 + Vector2i(0, 32),
			grid_position * 64 + Vector2i(27, 32),
			grid_position * 64 + Vector2i(64, 32),
			grid_position * 64 + Vector2i(37, 32),
		]
		if _wire_crossing_tiles[grid_position].horizontal_wire.state:
			green_lines.append_array(points)
		else:
			red_lines.append_array(points)
		points = [
			grid_position * 64 + Vector2i(32, 0),
			grid_position * 64 + Vector2i(32, 27),
			grid_position * 64 + Vector2i(32, 64),
			grid_position * 64 + Vector2i(32, 37),
		]
		if _wire_crossing_tiles[grid_position].vertical_wire.state:
			green_lines.append_array(points)
		else:
			red_lines.append_array(points)
	var gates: Dictionary[Vector2i, GateTile]
	for grid_position in _gate_tiles:
		if not _wire_tiles.has(grid_position):
			continue
		var points: PackedVector2Array
		# Input
		if _wire_tiles[grid_position].direction == EditorMode.Direction.RIGHT:
			points = [
				grid_position * 64 + Vector2i(58, 32),
				grid_position * 64 + Vector2i(64, 32),
			]
			if _wire_tiles[grid_position].state:
				green_lines.append_array(points)
				draw_circle(grid_position * 64 + Vector2i(58, 32), 3.5, Color.GREEN)
			else:
				red_lines.append_array(points)
				draw_circle(grid_position * 64 + Vector2i(58, 32), 3.5, Color.DARK_RED)
		# Output
		if _wire_tiles[grid_position].direction == EditorMode.Direction.LEFT:
			points = [
				grid_position * 64 + Vector2i(0, 32),
				grid_position * 64 + Vector2i(28, 32),
			]
			if _wire_tiles[grid_position].state:
				green_lines.append_array(points)
				draw_circle(grid_position * 64 + Vector2i(28, 32), 3.5, Color.GREEN)
			else:
				red_lines.append_array(points)
				draw_circle(grid_position * 64 + Vector2i(28, 32), 3.5, Color.DARK_RED)

		if _gates[_gate_tiles[grid_position]].gate == EditorMode.Gate.START:
			draw_circle(grid_position * 64 + Vector2i(32, 32), 12,
					Color.GREEN if _wire_tiles[grid_position].state else Color.DARK_RED)
			var two_points: PackedVector2Array = [
				grid_position * 64 + Vector2i(32, 32),
				grid_position * 64 + Vector2i(64, 32),
			]
			(green_lines if _wire_tiles[grid_position].state else red_lines).append_array(two_points)

			gates[grid_position] = _gates[_gate_tiles[grid_position]]
		if _gates[_gate_tiles[grid_position]].gate == EditorMode.Gate.STOP:
			draw_circle(grid_position * 64 + Vector2i(32, 32), 12,
					Color.GREEN if _wire_tiles[grid_position].state else Color.DARK_RED)
			var two_points: PackedVector2Array = [
				grid_position * 64 + Vector2i(32, 32),
				grid_position * 64 + Vector2i(0, 32),
			]
			(green_lines if _wire_tiles[grid_position].state else red_lines).append_array(two_points)

			gates[grid_position] = _gates[_gate_tiles[grid_position]]

	if not red_lines.is_empty():
		draw_multiline(red_lines, Color.DARK_RED, 7)
	if not green_lines.is_empty():
		draw_multiline(green_lines, Color.GREEN, 7)

	if not is_sandbox:
		var high_number := 15000
		var upper_left: Vector2i = dimension_limits[0] * 64
		var bottom_right: Vector2i = dimension_limits[1] * 64
		# Upper left shadow
		draw_rect(Rect2i(
				Vector2i(-high_number, -high_number),
				Vector2i(high_number, high_number) - upper_left.abs()),
				Color(Color.BLACK, 0.2))
		# Up shadow
		draw_rect(Rect2i(
				Vector2i(upper_left.x, -high_number),
				Vector2i(absi(upper_left.x) + absi(bottom_right.x) + 64, high_number - absi(upper_left.y))),
				Color(Color.BLACK, 0.2))
		# Upper right shadow
		draw_rect(Rect2i(
				Vector2i(bottom_right.x + 64, -high_number),
				Vector2i(high_number, high_number - absi(upper_left.y))),
				Color(Color.BLACK, 0.2))
		# Right shadow
		draw_rect(Rect2i(
				Vector2i(bottom_right.x + 64, upper_left.y),
				Vector2i(high_number, absi(upper_left.y) + absi(bottom_right.y) + 64)),
				Color(Color.BLACK, 0.2))
		# Bottom right shadow
		draw_rect(Rect2i(
				(bottom_right + Vector2i(64, 64)),
				Vector2i(high_number, high_number)),
				Color(Color.BLACK, 0.2))
		# Down shadow
		draw_rect(Rect2i(
				Vector2i(upper_left.x, bottom_right.y + 64),
				Vector2i(absi(upper_left.x) + absi(bottom_right.x) + 64, high_number)),
				Color(Color.BLACK, 0.2))
		# Bottom left shadow
		draw_rect(Rect2i(
				Vector2i(-high_number, bottom_right.y + 64),
				Vector2i(high_number - absi(upper_left.x), high_number)),
				Color(Color.BLACK, 0.2))
		# Left shadow
		draw_rect(Rect2i(
				Vector2i(-high_number, upper_left.y),
				Vector2i(high_number - absi(upper_left.x), (absi(upper_left.y) + absi(bottom_right.y) + 64))),
				Color(Color.BLACK, 0.2))

	for gate in gates:
		if gates[gate].gate == EditorMode.Gate.START:
			draw_string_outline(ThemeDB.fallback_font, (gate * 64) + Vector2i(-110, 36),
					_gates[_gate_tiles[gate]].display_name, HORIZONTAL_ALIGNMENT_RIGHT, 100, 16, 15,
					Color.BLACK)
			draw_string(ThemeDB.fallback_font, (gate * 64) + Vector2i(-110, 36),
					_gates[_gate_tiles[gate]].display_name, HORIZONTAL_ALIGNMENT_RIGHT, 100)
		else:
			draw_string_outline(ThemeDB.fallback_font, (gate * 64) + Vector2i(70, 36),
					_gates[_gate_tiles[gate]].display_name, HORIZONTAL_ALIGNMENT_LEFT, 100, 16, 15,
					Color.BLACK)
			draw_string(ThemeDB.fallback_font, (gate * 64) + Vector2i(70, 36),
					_gates[_gate_tiles[gate]].display_name, HORIZONTAL_ALIGNMENT_LEFT, 100)

	for gate in _custom_gates_input_pins_names:
		draw_string_outline(ThemeDB.fallback_font, (gate * 64) + Vector2i(-83, 14),
					_custom_gates_input_pins_names[gate], HORIZONTAL_ALIGNMENT_RIGHT, 100, 16, 15,
					Color.BLACK)
		draw_string(ThemeDB.fallback_font, (gate * 64) + Vector2i(-83, 14),
				_custom_gates_input_pins_names[gate], HORIZONTAL_ALIGNMENT_RIGHT, 100)
	for gate in _custom_gates_output_pins_names:
		draw_string_outline(ThemeDB.fallback_font, (gate * 64) + Vector2i(43, 14),
					_custom_gates_output_pins_names[gate], HORIZONTAL_ALIGNMENT_LEFT, 100, 16, 15,
					Color.BLACK)
		draw_string(ThemeDB.fallback_font, (gate * 64) + Vector2i(43, 14),
				_custom_gates_output_pins_names[gate], HORIZONTAL_ALIGNMENT_LEFT, 100)

	draw_set_transform(Vector2.ZERO, deg_to_rad(90))
	for placement in _custom_gates_names:
		var rotated_adjusted_placement: Vector2i = (Vector2i(placement.y, -placement.x) + Vector2i.UP) * 64 + Vector2i(30, 5)
		draw_string_outline(ThemeDB.fallback_font, rotated_adjusted_placement,
				_custom_gates_names[placement], HORIZONTAL_ALIGNMENT_LEFT, 100, 16, 15, Color.BLACK)
		draw_string(ThemeDB.fallback_font, rotated_adjusted_placement,
				_custom_gates_names[placement], HORIZONTAL_ALIGNMENT_LEFT, 100)


func place_wire() -> void:
	var wire_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	highlight_layer.clear_position_buffer()
	if wire_tiles.size() == 1:
		if _wire_tiles.has(wire_tiles[0]) and _wire_tiles[wire_tiles[0]].direction == 15:
			_wire_tiles.erase(wire_tiles[0])
			_wire_crossing_tiles[wire_tiles[0]] = WireCrossing.new()
		elif _wire_crossing_tiles.has(wire_tiles[0]):
			_wire_crossing_tiles.erase(wire_tiles[0])
			_wire_tiles[wire_tiles[0]] = WireTile.new(15)

		wire_layer.change_wire_crossing()
		return

	update_save_preview()

	var wire_types: Dictionary[Vector2i, Vector2i]
	var valid_tiles: Array[Vector2i]
	for tile in wire_tiles:
		if _gate_tiles.has(tile) or _wire_crossing_tiles.has(tile):
			continue
		if not is_sandbox:
			var wire_coodinates: Vector2i = tile
			if (
					wire_coodinates.x < dimension_limits[0].x
					or wire_coodinates.y < dimension_limits[0].y
					or wire_coodinates.x > dimension_limits[1].x
					or wire_coodinates.y > dimension_limits[1].y
			):
				continue

		wire_types[tile] = highlight_layer.get_cell_atlas_coords(tile)
		if wire_types[tile] == Vector2i(15, 1):
			_wire_crossing_tiles[tile] = WireCrossing.new()
			var wire: WireTile = _wire_tiles[tile]
			_wire_tiles.erase(tile)
			if wire.direction == EditorMode.Direction.RIGHT | EditorMode.Direction.LEFT:
				_wire_crossing_tiles[tile].horizontal_wire.state = wire.state
			if wire.direction == EditorMode.Direction.DOWN | EditorMode.Direction.UP:
				_wire_crossing_tiles[tile].vertical_wire.state = wire.state
			continue

		var tile_data: TileData = highlight_layer.get_cell_tile_data(tile)
		assert(tile_data, "What, how, huh?")
		var connected_directions: int = tile_data.get_custom_data("connected_directions")
		if _wire_tiles.has(tile) and _wire_tiles[tile].state:
			_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(tile, true,
			_logic_update_id))
		_wire_tiles[tile] = WireTile.new(connected_directions)
		valid_tiles.append(tile)
	wire_layer.create_wire(wire_types)
	for tile in valid_tiles:
		update_wire_for_neighbors(tile)

	highlight_layer.point_highlight()


func update_wire_for_neighbors(tile: Vector2i) -> void:
	if not _wire_tiles.has(tile) or _wire_crossing_tiles.has(tile):
		return
	var directions: Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.UP,
	]
	var directions_to: Array[int] = [4, 8, 1, 2]
	var directions_from: Array[int] = [1, 2, 4, 8]
	for index in range(4):
		var neighbor: Vector2i = tile + directions[index]
		# Delete connection
		if (
				not _wire_crossing_tiles.has(neighbor)
				and (_wire_tiles[tile].direction & directions_from[index]
				and (not _wire_tiles.has(neighbor)
				or not _wire_tiles[neighbor].direction & directions_to[index]))
		):
			_wire_tiles[tile].direction &= ~directions_from[index]
			update_signal(tile)
		# Add connection
		elif (
				_gate_tiles.has(neighbor)
				and _wire_tiles.has(neighbor)
				#and _wire_crossing_tiles.has(neighbor)
				and _wire_tiles[neighbor].direction & directions_to[index]
		):
			_wire_tiles[tile].direction |= directions_from[index]
			if _wire_tiles[neighbor].state:
				_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(tile, true,
						_logic_update_id))

	wire_layer.set_wire(tile, _wire_tiles[tile].direction)


func update_signal(tile: Vector2i) -> void:
	var wires: Array[Vector2i]
	var wire_spread: Array[Vector2i] = [tile]
	while not wire_spread.is_empty():
		var check_tile: Vector2i = wire_spread.pop_front()
		if _gate_tiles.has(check_tile) and _wire_tiles[check_tile].direction == EditorMode.Direction.RIGHT:
			return

		if not _wire_tiles.has(check_tile) and not _wire_crossing_tiles.has(check_tile):
			continue

		if _wire_tiles[check_tile].direction & EditorMode.Direction.RIGHT:
			if _wire_tiles.has(check_tile + Vector2i.RIGHT) and not wires.has(check_tile + Vector2i.RIGHT):
				wire_spread.append(check_tile + Vector2i.RIGHT)
			elif _wire_crossing_tiles.has(check_tile + Vector2i.RIGHT) and not wires.has(check_tile + (Vector2i.RIGHT) * 2):
				wire_spread.append(check_tile + (Vector2i.RIGHT * 2))
		if _wire_tiles[check_tile].direction & EditorMode.Direction.DOWN:
			if _wire_tiles.has(check_tile + Vector2i.DOWN) and not wires.has(check_tile + Vector2i.DOWN):
				wire_spread.append(check_tile + Vector2i.DOWN)
			elif _wire_crossing_tiles.has(check_tile + Vector2i.DOWN) and not wires.has(check_tile + (Vector2i.DOWN * 2)):
				wire_spread.append(check_tile + (Vector2i.DOWN * 2))
		if _wire_tiles[check_tile].direction & EditorMode.Direction.LEFT:
			if _wire_tiles.has(check_tile + Vector2i.LEFT) and not wires.has(check_tile + Vector2i.LEFT):
				wire_spread.append(check_tile + Vector2i.LEFT)
			elif _wire_crossing_tiles.has(check_tile + Vector2i.LEFT) and not wires.has(check_tile + (Vector2i.LEFT * 2)):
				wire_spread.append(check_tile + (Vector2i.LEFT * 2))
		if _wire_tiles[check_tile].direction & EditorMode.Direction.UP:
			if _wire_tiles.has(check_tile + Vector2i.UP) and not wires.has(check_tile + Vector2i.UP):
				wire_spread.append(check_tile + Vector2i.UP)
			elif _wire_crossing_tiles.has(check_tile + Vector2i.UP) and not wires.has(check_tile + (Vector2i.UP * 2)):
				wire_spread.append(check_tile + (Vector2i.UP * 2))

		#if wires.size() > 25:
			#print("Smaller")
			#wires.resize(10)
		wires.push_back(check_tile)
	_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(tile, false, _logic_update_id))


func place_gate() -> void:
	var gate_tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	var gate_data_cells: Dictionary[Vector2i, Dictionary]
	for tile in gate_tiles:
		if (
				_gate_tiles.has(tile) or untouchable_tiles.has(tile)
				or (not is_sandbox
				and (tile.x < dimension_limits[0].x
				or tile.y < dimension_limits[0].y
				or tile.x > dimension_limits[1].x
				or tile.y > dimension_limits[1].y))
		):
			return

		_wire_tiles.erase(tile)
		_wire_crossing_tiles.erase(tile)
		_update_neighboring_wires(tile)

		var cell_source_id: int = highlight_layer.get_cell_source_id(tile)
		var cell_atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(tile)
		gate_data_cells[tile] = {"source_id": cell_source_id, "atlas_coords": cell_atlas_coords}

	var new_gate_id: int = _next_free_gate_id
	_gates[new_gate_id] = GateTile.new(highlight_layer.get_cell_source_id(gate_tiles[0]) - 2)
	if gate_tiles.size() == 1:
		if _gates[new_gate_id].gate == EditorMode.Gate.START:
			_wire_tiles[gate_tiles[0]] = WireTile.new(1)

			_gates[new_gate_id].new_list_element(input_list_element)
			_gates[new_gate_id].set_element(gate_tiles[0], false)
			$"../WiresInterface/InputOutputView/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer".add_child(_gates[new_gate_id].list_element)
			_gates[new_gate_id].list_element.signal_set.connect(set_output)

			_gates[new_gate_id].outputs.append(gate_tiles[0])
		else:
			_wire_tiles[gate_tiles[0]] = WireTile.new(4)

			_gates[new_gate_id].new_list_element(output_list_element)
			$"../WiresInterface/InputOutputView/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer2/MarginContainer/VBoxContainer".add_child(_gates[new_gate_id].list_element)
			_gates[new_gate_id].set_element(gate_tiles[0], false)

			_gates[new_gate_id].inputs.append(gate_tiles[0])
		_gate_tiles[gate_tiles[0]] = new_gate_id
		_update_neighboring_wires(gate_tiles[0])
		$"../WiresInterface/GateNameWindow".visible = true
		$"../WiresInterface/GateNameWindow".edit_gate_name(_gates[new_gate_id])
	else:
		for tile in gate_tiles:
			_gate_tiles[tile] = new_gate_id
			if (
					highlight_layer.get_cell_atlas_coords(tile) == Vector2i.ZERO
					or highlight_layer.get_cell_atlas_coords(tile) == Vector2i(0, 2)
			):
				_wire_tiles[tile] = WireTile.new(4)
				_update_neighboring_wires(tile)
				if _wire_tiles.has(tile + Vector2i.LEFT):
					_wire_tiles[tile].state = _wire_tiles[tile + Vector2i.LEFT].state
				_callable_queue.push_back(Callable(self, &"_get_into_gate").bind(tile))
				_gates[new_gate_id].inputs.append(tile)
			elif (
					highlight_layer.get_cell_atlas_coords(tile) == Vector2i(2, 1)
					or (_gates[new_gate_id].gate == EditorMode.Gate.NOT
					and highlight_layer.get_cell_atlas_coords(tile) == Vector2i(2, 0))
			):
				_wire_tiles[tile] = WireTile.new(1)
				_update_neighboring_wires(tile)
				_gates[new_gate_id].outputs.append(tile)
	wire_layer.create_gate(gate_data_cells)

	update_save_preview()


func process_queue(iterations: int) -> void:
	if _callable_queue.is_empty():
		#queue_redraw()
		queue_cleared.emit()
		return
	for i in range(iterations):
		if _callable_queue.is_empty():
			queue_cleared.emit()
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
	if not _wire_tiles.has(grid_position):
		return
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
			if _gate_tiles.has(next_tile_position) and _wire_tiles[next_tile_position].direction == 1 and not _wire_tiles[next_tile_position].state == state:
				_wire_tiles.erase(grid_position)
				wire_layer.erase_cell(grid_position)
				_update_neighboring_wires(grid_position)
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
	if not _gate_tiles.has(grid_position):
		return
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
	elif gate_type == EditorMode.Gate.STOP:
		if is_sandbox:
			this_gate_tile.set_element(Vector2i.ZERO, inputs[0])
	elif gate_type == EditorMode.Gate.CUSTOM:
		if not _custom_gate_tiles.has(grid_position):
			return
		var the_gate: CustomGate = _custom_gate_tiles[grid_position].inner_workings
		the_gate._spread_wire_logic(_custom_gate_tiles[grid_position].swap_coordinate, _wire_tiles[grid_position].state, _logic_update_id)

	for index in outputs.size():
		_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(
				output_coordinates[index], outputs[index], _logic_update_id))


func load_file(path: String) -> bool:
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
				var new_wire: WireTile = WireTile.new(direction)
				new_wire.state = state
				_wire_tiles[tile] = new_wire

				wire_layer.set_cell(tile, 0, Vector2i(direction, 0))
			else:
				var wire_crossing: WireCrossing = WireCrossing.new()
				var state: bool = wire_tile["horizontal_wire"]["state"]
				wire_crossing.horizontal_wire.state = state
				state = wire_tile["vertical_wire"]["state"]
				wire_crossing.vertical_wire.state = state
				_wire_crossing_tiles[tile] = wire_crossing

				wire_layer.set_cell(tile, 0, Vector2i(15, 1))

	var gates_dictionary: Dictionary = everything_dictionary["gates"]
	for gate: String in gates_dictionary:
		var gate_id: int = int(gate)
		_next_free_gate_id = gate_id
		var gate_type: EditorMode.Gate = gates_dictionary[gate]["gate"]

		var inputs: Array[Vector2i]
		for input: String in gates_dictionary[gate]["inputs"]:
			inputs.append(str_to_var("Vector2i" + input))
		var outputs: Array[Vector2i]
		for output: String in gates_dictionary[gate]["outputs"]:
			outputs.append(str_to_var("Vector2i" + output))
		var display_name: String
		if gates_dictionary[gate].has("name"):
			display_name = gates_dictionary[gate]["name"]

		var new_gate: GateTile = GateTile.new(gate_type)
		new_gate.inputs = inputs
		new_gate.outputs = outputs
		new_gate.display_name = display_name
		_gates[gate_id] = new_gate

		if gate_type == EditorMode.Gate.CUSTOM:
			# TODO Load up custom gate from file

			var gate_path: String = "%s/%s.circuit" % [Filepaths.custom_gates_directory, gates_dictionary[gate]["name"]]
			load_custom_gate(gate_path)

			create_custom_gate_from_dict()

			# search for output gates
			var custom_inputs: Array[Vector2i]
			var custom_outputs: Array[Vector2i]
			for potential_gate: String in _custom_gate_dict["gates"]:
				if _custom_gate_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.START:
					custom_inputs.append(str_to_var("Vector2i" + _custom_gate_dict["gates"][potential_gate]["outputs"][0]))
				elif _custom_gate_dict["gates"][potential_gate]["gate"] == EditorMode.Gate.STOP:
					custom_outputs.append(str_to_var("Vector2i" + _custom_gate_dict["gates"][potential_gate]["inputs"][0]))
			custom_inputs.sort_custom(sort_by_y_first)
			custom_outputs.sort_custom(sort_by_y_first)

			for input_index in range(custom_inputs.size()):
				_custom_gate_tiles[str_to_var("Vector2i" + gates_dictionary[gate]["inputs"][input_index])] = CustomGateTile.new(gate_path, _custom_gates[-1], custom_inputs[input_index])
				_custom_gates_input_pins_names[str_to_var("Vector2i" + gates_dictionary[gate]["inputs"][input_index])] = _custom_gates[-1]._gates[_custom_gates[-1]._gate_tiles[custom_inputs[input_index]]].display_name
			for output_index in range(custom_outputs.size()):
				_custom_gates[-1].exits[custom_outputs[output_index]] = str_to_var("Vector2i" + gates_dictionary[gate]["outputs"][output_index])
				_custom_gates_output_pins_names[str_to_var("Vector2i" + gates_dictionary[gate]["outputs"][output_index])] = _custom_gates[-1]._gates[_custom_gates[-1]._gate_tiles[custom_outputs[output_index]]].display_name

			var gate_center_place: Vector2i = str_to_var("Vector2i" + gates_dictionary[gate]["inputs"][0])
			_custom_gates_names[gate_center_place] = gates_dictionary[gate]["name"]

			#for custom_input in custom_inputs:
				#print(_custom_gates[-1]._gates[_custom_gates[-1]._gate_tiles[custom_input]].display_name)

			var custom_gate_pins: Vector2i
			custom_gate_pins.x = gates_dictionary[gate]["inputs"].size()
			custom_gate_pins.y = gates_dictionary[gate]["outputs"].size()
			wire_layer.load_custom_gate(custom_gate_pins, gate_center_place)

			for update_position_string: String in gates_dictionary[gate]["inputs"]:
				var update_position: Vector2i = str_to_var("Vector2i" + update_position_string)
				_callable_queue.push_back(Callable(self, &"_get_into_gate").bind(update_position))

			continue

		var min_pos: Vector2i
		if new_gate.inputs.is_empty():
			min_pos = new_gate.outputs[0]
		else:
			min_pos = new_gate.inputs[0]
		var max_pos: Vector2i
		if new_gate.outputs.is_empty():
			max_pos = new_gate.inputs[0]
		else:
			max_pos = new_gate.outputs[0]

		for input: Vector2i in new_gate.inputs:
			min_pos.x = min(input.x, min_pos.x)
			min_pos.y = min(input.y, min_pos.y)
			max_pos.x = max(input.x, max_pos.x)
			max_pos.y = max(input.y, max_pos.y)
		for output: Vector2i in new_gate.outputs:
			min_pos.x = min(output.x, min_pos.x)
			min_pos.y = min(output.y, min_pos.y)
			max_pos.x = max(output.x, max_pos.x)
			max_pos.y = max(output.y, max_pos.y)

		var atlas_coords: Vector2i
		for y in range(min_pos.y, max_pos.y + 1):
			atlas_coords.x = 0
			for x in range(min_pos.x, max_pos.x + 1):
				wire_layer.set_cell(Vector2i(x, y), gate_type + 2, atlas_coords)
				atlas_coords.x = atlas_coords.x + 1
			atlas_coords.y = atlas_coords.y + 1

		if gate_type == EditorMode.Gate.START:
			wire_layer.set_cell(outputs[0], 9, Vector2i.ZERO)
		if gate_type == EditorMode.Gate.STOP:
			wire_layer.set_cell(inputs[0], 10, Vector2i.ZERO)

	update_save_preview()
	return true
	# TODO return false in case of failure


func create_custom_gate_from_dict() -> void:
	var new_custom_gate := CustomGate.new(_callable_queue, self)
	_custom_gates.append(new_custom_gate)

	var gates_dictionary: Dictionary = _custom_gate_dict["gates"]

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

		var new_gate: GateTile = GateTile.new(gate_type)
		new_gate.inputs = inputs
		new_gate.outputs = outputs
		if gates_dictionary[gate].has("name"):
			new_gate.display_name = gates_dictionary[gate]["name"]
		new_custom_gate._gates[int(gate)] = new_gate

	var placement_dictionary: Dictionary = _custom_gate_dict["placement"]
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
				var new_wire: WireTile = WireTile.new(direction)
				new_wire.state = state
				new_custom_gate._wire_tiles[tile] = new_wire
			else:
				var wire_crossing: WireCrossing = WireCrossing.new()
				var state: bool = wire_tile["horizontal_wire"]["state"]
				wire_crossing.horizontal_wire.state = state
				state = wire_tile["vertical_wire"]["state"]
				wire_crossing.vertical_wire.state = state
				new_custom_gate._wire_crossing_tiles[tile] = wire_crossing


func load_custom_gate(path: String) -> void:
	_custom_gate_dict = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var loaded_gates_dict: Dictionary = _custom_gate_dict["gates"]
	var inputs := 0
	var outputs := 0
	for id: String in loaded_gates_dict:
		var gate: Dictionary = loaded_gates_dict[id]
		if gate["gate"] == 7:
			inputs = inputs + 1
		elif gate["gate"] == 8:
			outputs = outputs + 1
	highlight_layer._custom_gate_pins = Vector2i(inputs, outputs)
	# TODO włożyć gdzieś te wejścia/wyjścia


func sort_by_y_first(a: Vector2i, b: Vector2i) -> bool:
	if a.y < b.y:
		return true
	if a.y == b.y:
		return a.x <= b.x
	return false


func place_custom_gate(path: String) -> void:
	var new_custom_gate := CustomGate.new(_callable_queue, self)
	_custom_gates.append(new_custom_gate)

	var gates_ids: Array[int]
	var placement_dictionary: Dictionary = _custom_gate_dict["placement"]
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
				var new_wire: WireTile = WireTile.new(direction)
				new_wire.state = state
				new_custom_gate._wire_tiles[tile] = new_wire
			else:
				var wire_crossing: WireCrossing = WireCrossing.new()
				var state: bool = wire_tile["horizontal_wire"]["state"]
				wire_crossing.horizontal_wire.state = state
				state = wire_tile["vertical_wire"]["state"]
				wire_crossing.vertical_wire.state = state
				new_custom_gate._wire_crossing_tiles[tile] = wire_crossing

	var loaded_gates_dict: Dictionary = _custom_gate_dict["gates"]

	var gate_inputs: Array[Vector2i]
	var gate_outputs: Array[Vector2i]
	# Fill data for all gates inside.
	for gate: String in loaded_gates_dict:
		var gate_type: EditorMode.Gate = loaded_gates_dict[gate]["gate"]
		var inputs_inside: Array[Vector2i]
		for input: String in loaded_gates_dict[gate]["inputs"]:
			inputs_inside.append(str_to_var("Vector2i" + input))
		var outputs_inside: Array[Vector2i]
		for output: String in loaded_gates_dict[gate]["outputs"]:
			outputs_inside.append(str_to_var("Vector2i" + output))

		if gate_type == EditorMode.Gate.START:
			gate_inputs.append(outputs_inside[0])
		elif gate_type == EditorMode.Gate.STOP:
			gate_outputs.append(inputs_inside[0])

		var new_gate: GateTile = GateTile.new(gate_type)
		new_gate.inputs = inputs_inside
		new_gate.outputs = outputs_inside
		if loaded_gates_dict[gate].has("name"):
			new_gate.display_name = loaded_gates_dict[gate]["name"]
		new_custom_gate._gates[int(gate)] = new_gate

	var tiles: Array[Vector2i] = highlight_layer.get_used_cells()
	for tile in tiles:
		if _gate_tiles.has(tile):
			return

	var inputs: Array[Vector2i]
	var outputs: Array[Vector2i]
	var next_gate_id: int = _next_free_gate_id
	_gates[next_gate_id] = GateTile.new(EditorMode.Gate.CUSTOM)
	for tile in tiles:
		var atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(tile)
		if atlas_coords.x == 0:
			inputs.append(tile)
			_wire_tiles[tile] = WireTile.new(4)
		elif atlas_coords.x == 1:
			outputs.append(tile)
			_wire_tiles[tile] = WireTile.new(1)

		_gate_tiles[tile] = next_gate_id
		wire_layer.set_cell(tile, 11, atlas_coords)

	_gates[next_gate_id].inputs = inputs
	_gates[next_gate_id].outputs = outputs

	inputs.sort_custom(sort_by_y_first)
	outputs.sort_custom(sort_by_y_first)
	gate_inputs.sort_custom(sort_by_y_first)
	gate_outputs.sort_custom(sort_by_y_first)

	for input in range(inputs.size()):
		_custom_gate_tiles[inputs[input]] = CustomGateTile.new(path, new_custom_gate, gate_inputs[input])
		_custom_gates_input_pins_names[inputs[input]] = _custom_gates[-1]._gates[_custom_gates[-1]._gate_tiles[gate_inputs[input]]].display_name
	for output in range(outputs.size()):
		new_custom_gate.exits[gate_outputs[output]] = outputs[output]
		_custom_gates_output_pins_names[outputs[output]] = _custom_gates[-1]._gates[_custom_gates[-1]._gate_tiles[gate_outputs[output]]].display_name

	_custom_gates_names[inputs[0]] = path.get_file().trim_suffix(".circuit")
	_gates[next_gate_id].display_name = _custom_gates_names[inputs[0]]


func level_dimension_limiter(left_up: Vector2i, bottom_right: Vector2i) -> void:
	dimension_limits = [left_up, bottom_right]


func toggle_output() -> void:
	var grid_mouse_position: Vector2i = wire_layer.local_to_map(get_local_mouse_position())
	if _gate_tiles.has(grid_mouse_position):
		if _gates[_gate_tiles[grid_mouse_position]].gate == EditorMode.Gate.START:
			var state: bool = not _wire_tiles[grid_mouse_position].state
			set_output(grid_mouse_position, state)
			_gates[_gate_tiles[grid_mouse_position]].list_element._on_button_pressed()


func set_output(grid_position: Vector2i, state: bool) -> void:
	_callable_queue.push_back(Callable(self, &"_spread_wire_logic").bind(grid_position, state,
			_logic_update_id))
	wire_layer.set_start_gate(grid_position, state)
	play_ui_sound.emit()


func save_circuit(path: String) -> void:
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

	var saved: bool = FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(save_dict, "\t"))
	if not saved:
		printerr("Couldn't save file: " + path)


func _on_file_dialog_file_selected(path: String) -> void:
	save_circuit(path)
	play_ui_sound.emit()


func update_save_preview() -> void:
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
	$"../WiresInterface/CodeEdit".text = JSON.stringify(save_dict, "\t")


func delete_stuff() -> void:
	var grid_position: Vector2i = highlight_layer._mouse_to_grid()
	if not is_sandbox:
		if untouchable_tiles.has(grid_position):
			return
	if _gate_tiles.has(grid_position):
		var gate_id: int = _gate_tiles[grid_position]
		var keys_to_remove: Array[Vector2i]
		for gate_position in _gate_tiles:
			if _gate_tiles[gate_position] == gate_id:
				keys_to_remove.append(gate_position)
		for key in keys_to_remove:
			_gate_tiles.erase(key)
			_custom_gates_names.erase(key)
			_custom_gates_input_pins_names.erase(key)
			_custom_gates_output_pins_names.erase(key)

			var had_wire: bool = _wire_tiles.erase(key)
			if had_wire:
				_update_neighboring_wires(key)

			wire_layer.erase_cell(key)
		if _gates[gate_id].gate == EditorMode.Gate.START or _gates[gate_id].gate == EditorMode.Gate.STOP:
			_gates[gate_id].list_element.queue_free()
		_gates.erase(gate_id)
	elif _wire_tiles.has(grid_position) or _wire_crossing_tiles.has(grid_position):
		wire_layer.erase_cell(grid_position)
		_wire_tiles.erase(grid_position)
		_wire_crossing_tiles.erase(grid_position)

		_update_neighboring_wires(grid_position)


func _update_neighboring_wires(grid_position: Vector2i) -> void:
	var neighbor_directions: Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.UP,
	]
	for next_neighbor in neighbor_directions:
		var neighbor_tile: Vector2i = grid_position + next_neighbor
		if _gate_tiles.has(neighbor_tile):
			continue
		if _wire_crossing_tiles.has(neighbor_tile):
			_wire_crossing_tiles.erase(neighbor_tile)
			_wire_tiles[neighbor_tile] = WireTile.new(15)
		if _wire_tiles.has(neighbor_tile):
			update_wire_for_neighbors(neighbor_tile)


func clear() -> void:
	_custom_gate_dict.clear()
	_callable_queue = DoubleLinkedListCallable.new()
	_next_free_gate_id = 0
	_logic_update_id = 0
	_wire_tiles.clear()
	_wire_crossing_tiles.clear()
	_gate_tiles.clear()
	_gates.clear()
	_custom_gates.clear()
	_custom_gate_tiles.clear()
	_custom_gates_names.clear()
	_custom_gates_input_pins_names.clear()
	_custom_gates_output_pins_names.clear()

	wire_layer.clear()
	highlight_layer.clear()

	for node in $"../WiresInterface/InputOutputView/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer".get_children():
		node.queue_free()
	for node in $"../WiresInterface/InputOutputView/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer2/MarginContainer/VBoxContainer".get_children():
		node.queue_free()


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
		return {
			"horizontal_wire": horizontal_wire.to_dict(),
			"vertical_wire": vertical_wire.to_dict(),
		}


class GateTile:
	var gate: EditorMode.Gate
	var inputs: Array[Vector2i]
	var outputs: Array[Vector2i]
	var display_name: String

	var list_element: Node


	func _init(new_gate_type: EditorMode.Gate) -> void:
		gate = new_gate_type


	func to_dict() -> Dictionary:
		var buff: Dictionary = {
			"gate": gate,
			"inputs": inputs,
			"outputs": outputs,
		}
		if display_name:
			buff["name"] = display_name

		return buff


	func set_name(new_name: String) -> void:
		display_name = new_name
		list_element.set_display(new_name)


	func new_list_element(scene: PackedScene) -> void:
		list_element = scene.instantiate()


	func set_element(grid_position: Vector2i, new_state: bool) -> void:
		list_element.set_element(grid_position, new_state)


class CustomGateTile:
	var file_path: String
	var swap_coordinate: Vector2i
	var inner_workings: CustomGate


	func _init(new_file_path: String, new_inner_workings: CustomGate, new_swap_coordinate: Vector2i) -> void:
		file_path = new_file_path
		swap_coordinate = new_swap_coordinate
		inner_workings = new_inner_workings


	func to_dict() -> Dictionary:
		return {
			"gate": file_path,
			"swap_coordinate": swap_coordinate,
		}
