class_name WireLogic
extends Node2D

var buffer_position: Array[Vector2i]
var rotated: bool = false

@onready var logic_layer: TileMapLayer = $LogicLayer
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer


func add_checkpoint(mouse_position: Vector2i) -> void:
	buffer_position.append(mouse_position)
	buffer_position.append(mouse_position)

	rotated = false


func rotate_checkpoint() -> void:
	var buff: Vector2i
	buff = buffer_position[-1]
	buffer_position[-1] = buffer_position[-2]
	buffer_position[-2] = buff

	rotated = not rotated


func highlight_wire(mouse_position: Vector2i) -> void:
	highlight_layer.clear()

	for index in range(0, buffer_position.size(), 2):
		if index == buffer_position.size() - 2:
			if rotated:
				buffer_position[-2] = mouse_position
			else:
				buffer_position[-1] = mouse_position

		var starting_position: Vector2i = buffer_position[index]
		var ending_position: Vector2i = buffer_position[index + 1]

		var direction := Vector2i(ending_position - starting_position).sign()

		if direction.y != 0:
			highlight_line(starting_position, Vector2i(starting_position.x, ending_position.y))

			#for position_y in range(starting_position.y, ending_position.y + direction.y, direction.y):
				#update_wire_tile(Vector2i(starting_position.x, position_y), direction)
				# TODO - Wykonać aby kable w jednej osi się łączyły może? A potem do następnej osi
				# po prostu połączy osobno?
				#highlight_layer.set_cell(Vector2i(starting_position.x, position_y), 0, Vector2i(4, 0), 0)
		if direction.x != 0:
			highlight_line(Vector2i(starting_position.x, ending_position.y), ending_position)

			#for position_x in range(starting_position.x, ending_position.x + direction.x, direction.x):
				#highlight_layer.set_cell(Vector2i(position_x, ending_position.y), 0, Vector2i(4, 0), 0)


func highlight_line(starting_position: Vector2i, ending_position: Vector2i) -> void:
	var direction: Vector2i = (ending_position - starting_position).sign()

	if direction.x:
		for buffer_position in range(starting_position.x, ending_position.x + direction.x, direction.x):
			update_wire_tile(Vector2i(buffer_position, starting_position.y), direction)
			update_wire_tile(Vector2i(buffer_position, starting_position.y), -direction)
	else:
		for buffer_position in range(starting_position.y, ending_position.y + direction.y, direction.y):
			update_wire_tile(Vector2i(starting_position.x, buffer_position), direction)
			update_wire_tile(Vector2i(starting_position.x, buffer_position), -direction)


func update_wire_tile(tile_position: Vector2i, new_direction: Vector2i) -> void:
	var right_direction: bool = false
	var down_direction: bool = false
	var left_direction: bool = false
	var up_direction: bool = false

	var data: TileData = highlight_layer.get_cell_tile_data(tile_position)
	if data:
		if data.get_custom_data("right_direction"):
			right_direction = true
		if data.get_custom_data("down_direction"):
			down_direction = true
		if data.get_custom_data("left_direction"):
			left_direction = true
		if data.get_custom_data("up_direction"):
			up_direction = true
	data = wire_layer.get_cell_tile_data(tile_position)
	if data:
		if data.get_custom_data("right_direction"):
			right_direction = true
		if data.get_custom_data("down_direction"):
			down_direction = true
		if data.get_custom_data("left_direction"):
			left_direction = true
		if data.get_custom_data("up_direction"):
			up_direction = true

	if new_direction == Vector2i.RIGHT:
		right_direction = true
	elif new_direction == Vector2i.DOWN:
		down_direction = true
	elif new_direction == Vector2i.LEFT:
		left_direction = true
	elif new_direction == Vector2i.UP:
		up_direction = true

	if right_direction:
		if down_direction:
			if left_direction:
				if up_direction:
					# right, down, left, top
					highlight_layer.set_cell(tile_position, 0, Vector2i(4, 0), 0)
					return
				# right, down, left
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 0)
				return
			elif up_direction:
				# right, down, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 3)
				return
			# right, down
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 0)
			return
		elif left_direction:
			if up_direction:
				# right, left, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 2)
				return
			# right, left
			highlight_layer.set_cell(tile_position, 0, Vector2i(1, 0), 1)
			return
		elif up_direction:
			# right, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 3)
			return
		# right
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 3)
		return
	elif down_direction:
		if left_direction:
			if up_direction:
				# down, left, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 1)
				return
			# down, left
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 1)
			return
		elif up_direction:
			# down, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(1, 0), 0)
			return
		# down
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 0)
		return
	elif left_direction:
		if up_direction:
			# left, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 2)
			return
		# left
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 1)
		return
	elif up_direction:
		# top
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 2)
		return
	highlight_layer.set_cell(tile_position, 0, Vector2i(5, 0), 0)


func draw_wire() -> void:
	buffer_position.clear()
