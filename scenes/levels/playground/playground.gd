extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer
@export var wires_interface: WiresInterface

var mode_selected: EditorMode.Mode = EditorMode.Mode.WIRE
var gate_selected: EditorMode.Gate = EditorMode.Gate.STARTSTOP


func _process(_delta: float) -> void:
	wires_interface.update_queue_size(wire_layer._logic_queue.size())


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
				$Wires.place_on_grid()
			if event.is_action_pressed(&"destroy"):
				wire_layer.delete_stuff()
			if event is InputEventMouseMotion:
				if Input.is_action_pressed(&"place"):
					highlight_layer.wire_highlight()
				else:
					highlight_layer.point_highlight()
				if Input.is_action_pressed(&"destroy"):
					wire_layer.delete_stuff()
		# gate behavior
		_:
			if event.is_action_pressed(&"place"):
				$Wires.place_on_grid()
			if event.is_action_pressed(&"rotate"):
				highlight_layer.rotate_gate()
				highlight_layer.gate_highlight(gate_selected)
			if event.is_action_pressed(&"destroy"):
				wire_layer.delete_stuff()
			if event is InputEventMouseMotion:
				highlight_layer.gate_highlight(gate_selected)


func _on_wires_interface_mode_selected(mode: EditorMode.Mode, gate: EditorMode.Gate) -> void:
	mode_selected = mode
	gate_selected = gate

	if mode == EditorMode.Mode.SELECT:
		highlight_layer.clear()
