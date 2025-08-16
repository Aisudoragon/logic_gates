class_name Wires extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer


func place_on_grid() -> void:
	var all_tiles_coords: Array[Vector2i] = highlight_layer.get_used_cells()
	for tile in all_tiles_coords:
		wire_layer.set_cell(tile, highlight_layer.get_cell_source_id(tile),
				highlight_layer.get_cell_atlas_coords(tile),
				highlight_layer.get_cell_alternative_tile(tile))
	highlight_layer.clear_position_buffer()


#func destroy_gate(mouse_pos: Vector2i = get_mouse_pos()) -> void:
	#var delete_position: Vector2i
	#var source := 2
	#match gate_layer.get_cell_atlas_coords(mouse_pos):
		#Vector2i(0, 0):
			#delete_position = mouse_pos + Vector2i.RIGHT
			#if gate_layer.get_cell_source_id(mouse_pos) == 1:
				#source = 1
			#else:
				#delete_position += Vector2i.DOWN
		#Vector2i(1, 0):
			#delete_position = mouse_pos
			#if gate_layer.get_cell_source_id(mouse_pos) == 1:
				#source = 1
			#else:
				#delete_position += Vector2i.DOWN
		#Vector2i(2, 0):
			#delete_position = mouse_pos + Vector2i.LEFT
			#if gate_layer.get_cell_source_id(mouse_pos) == 1:
				#source = 1
			#else:
				#delete_position += Vector2i.DOWN
		#Vector2i(0, 1):
			#delete_position = mouse_pos + Vector2i.RIGHT
		#Vector2i(1, 1):
			#delete_position = mouse_pos
		#Vector2i(2, 1):
			#delete_position = mouse_pos + Vector2i.LEFT
		#Vector2i(0, 2):
			#delete_position = mouse_pos + Vector2i.RIGHT + Vector2i.UP
		#Vector2i(1, 2):
			#delete_position = mouse_pos + Vector2i.UP
		#Vector2i(2, 2):
			#delete_position = mouse_pos + Vector2i.LEFT + Vector2i.UP
		#_:
			#print("NOTHING")
			#return
	#place_gate_on_layer(source, delete_position)
