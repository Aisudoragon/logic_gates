extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer
@export var wires: Wires
@export var wires_interface: WiresInterface

signal change_scene_main_menu()

var mode_selected: EditorMode.Mode = EditorMode.Mode.WIRE
var gate_selected: EditorMode.Gate = EditorMode.Gate.START
var highlight := false
var custom_gate_path: String


func _process(_delta: float) -> void:
	wires_interface.update_queue_size(wires._callable_queue.size())
	wires_interface.visible = visible
	$Camera2D.anchor_mode = int(visible)
	pass


func _unhandled_input(event: InputEvent) -> void:
	wires_interface.update_coordinates(highlight_layer._mouse_to_grid())
	match mode_selected:
		EditorMode.Mode.SELECT:
			if event.is_action_pressed(&"place"):
				wire_layer.toggle_start_gate()
		EditorMode.Mode.WIRE:
			if event.is_action_pressed(&"place") or event.is_action_pressed(&"special"):
				highlight_layer.add_checkpoint()
			if event.is_action_pressed(&"rotate"):
				highlight_layer.change_direction_line()
				highlight_layer.wire_highlight()
			if event.is_action_released(&"place"):
				wires.place_wire()
			if event.is_action_pressed(&"destroy"):
				wire_layer.delete_stuff()
			if event is InputEventMouseMotion and highlight:
				if Input.is_action_pressed(&"place"):
					highlight_layer.wire_highlight()
				else:
					highlight_layer.point_highlight()
				if Input.is_action_pressed(&"destroy"):
					wire_layer.delete_stuff()
		# gate behavior
		EditorMode.Mode.GATE:
			if event.is_action_pressed(&"place"):
				if gate_selected == EditorMode.Gate.CUSTOM:
					wires.place_custom_gate(custom_gate_path)
					pass
				else:
					wires.place_gate()
			if event.is_action_pressed(&"destroy"):
				wire_layer.delete_stuff()
			if event is InputEventMouseMotion and highlight:
				if gate_selected == EditorMode.Gate.CUSTOM:
					highlight_layer.custom_gate_highlight()
				else:
					highlight_layer.gate_highlight(gate_selected)


func propagade_file_path(path: String) -> void:
	wires.load_file(path)
	$WiresInterface/SaveButtons.save_path = path


func _on_wires_interface_mode_selected(mode: EditorMode.Mode, gate: EditorMode.Gate) -> void:
	mode_selected = mode
	gate_selected = gate

	if mode == EditorMode.Mode.SELECT:
		highlight_layer.clear()
	if gate == EditorMode.Gate.CUSTOM:
		highlight = false
		$WiresInterface/GateDialog.visible = true
	else:
		highlight = true


func _on_back_button_pressed() -> void:
	change_scene_main_menu.emit()
	wires.clear()
	$Camera2D.position = Vector2.ZERO
	$Camera2D.zoom = Vector2(1, 1)


func _on_gate_dialog_file_selected(path: String) -> void:
	custom_gate_path = path
	wires.load_custom_gate(path)
	highlight = true
