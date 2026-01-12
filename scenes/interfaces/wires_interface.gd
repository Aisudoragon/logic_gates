class_name WiresInterface extends CanvasLayer

@export var debug_coordinates: Label
@export var debug_queue_size: Label

signal mode_selected(mode: EditorMode.Mode, gate: EditorMode.Gate)


func enable_buttons(bitmask: int) -> void:
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceCustom.visible = false
	else:
		$HBoxContainer/PlaceCustom.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceXnor.visible = false
	else:
		$HBoxContainer/PlaceXnor.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceXor.visible = false
	else:
		$HBoxContainer/PlaceXor.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceNor.visible = false
	else:
		$HBoxContainer/PlaceNor.visible = false
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceOr.visible = false
	else:
		$HBoxContainer/PlaceOr.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceNand.visible = false
	else:
		$HBoxContainer/PlaceNand.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceAnd.visible = false
	else:
		$HBoxContainer/PlaceAnd.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceNot.visible = false
	else:
		$HBoxContainer/PlaceNot.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceEnd.visible = false
	else:
		$HBoxContainer/PlaceEnd.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/PlaceStart.visible = false
	else:
		$HBoxContainer/PlaceStart.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/DrawWire.visible = false
	else:
		$HBoxContainer/DrawWire.visible = true
	bitmask = bitmask >> 1
	if bitmask & 1 == 0:
		$HBoxContainer/SelectThings.visible = false
	else:
		$HBoxContainer/SelectThings.visible = true


func update_coordinates(mouse_pos: Vector2i) -> void:
	debug_coordinates.text = "%d, %d" % [mouse_pos.x, mouse_pos.y]


func update_queue_size(size: int) -> void:
	debug_queue_size.text = "%d : kolejka" % size


func _on_select_things_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.SELECT, EditorMode.Gate.START)


func _on_draw_wire_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.WIRE, EditorMode.Gate.START)


func _on_place_start_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.START)


func _on_place_end_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.STOP)


func _on_place_not_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.NOT)


func _on_place_and_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.AND)


func _on_place_nand_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.NAND)


func _on_place_or_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.OR)


func _on_place_nor_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.NOR)


func _on_place_xor_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.XOR)


func _on_place_xnor_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.XNOR)


func _on_place_custom_pressed() -> void:
	mode_selected.emit(EditorMode.Mode.GATE, EditorMode.Gate.CUSTOM)
