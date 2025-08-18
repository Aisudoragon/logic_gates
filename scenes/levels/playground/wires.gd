class_name Wires extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer


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
