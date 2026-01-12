class_name Playground extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer
@export var wires: Wires
@export var wires_interface: WiresInterface
@export var objective_text: RichTextLabel
@export var helpful_text: RichTextLabel

signal change_scene_main_menu()
signal change_scene_level_selection()

var mode_selected: EditorMode.Mode = EditorMode.Mode.WIRE
var gate_selected: EditorMode.Gate = EditorMode.Gate.START
var highlight := false
var custom_gate_path: String

var level_selected: int
var checking_sequence: Array[Vector2i]


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
				if wires.is_sandbox and not wires.untouchable_tiles.has(highlight_layer._mouse_to_grid()):
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
				wires.delete_stuff()
			if event is InputEventMouseMotion and highlight:
				if Input.is_action_pressed(&"place"):
					highlight_layer.wire_highlight()
				else:
					highlight_layer.point_highlight()
				if Input.is_action_pressed(&"destroy"):
					wires.delete_stuff()
		# gate behavior
		EditorMode.Mode.GATE:
			if event.is_action_pressed(&"place"):
				if gate_selected == EditorMode.Gate.CUSTOM:
					wires.place_custom_gate(custom_gate_path)
					pass
				else:
					wires.place_gate()
			if event.is_action_pressed(&"destroy"):
				wires.delete_stuff()
			if event is InputEventMouseMotion and highlight:
				if gate_selected == EditorMode.Gate.CUSTOM:
					highlight_layer.custom_gate_highlight()
				else:
					highlight_layer.gate_highlight(gate_selected)


func propagade_file_path(path: String) -> void:
	wires.load_file(path)
	$WiresInterface/SaveButtons.save_path = path


func load_level(id: int) -> void:
	$WiresInterface/SaveButtons/BackButton.visible = false
	$WiresInterface/SaveButtons/BackButton2.visible = true
	$WiresInterface/SaveButtons/SaveButton.visible = false
	$ObjectiveLayer.visible = true
	match id:
		1:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires.untouchable_tiles = [Vector2i(1, -1), Vector2i(5, -1)]
			wires.is_sandbox = false
			level_selected = 1
			checking_sequence = [Vector2i(1, -1)]
			objective_text.text = """[center][font_size=28]Zadanie 1[/font_size][/center]

Na początek coś prostego.
[ul][color=red]Połącz oba końce w jeden kabel[/color][/ul]"""
			helpful_text.text = """Kliknij przycisk "KABEL", przytrzymaj lewy przycisk myszy na jednym końcu i przeciągnij do drugiego końca."""
			wires_interface.enable_buttons(0b1100_0000_0000)
			wires.load_file("res://scenes/levels/level_1.json")
		_:
			print("Invalid level selected. How?")


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


func _on_back_button_2_pressed() -> void:
	$WiresInterface/SaveButtons/BackButton.visible = true
	$WiresInterface/SaveButtons/BackButton2.visible = false
	$WiresInterface/SaveButtons/SaveButton.visible = true
	$ObjectiveLayer.visible = false
	wires_interface.enable_buttons(0b1111_1111_1111)
	level_selected = 0
	change_scene_level_selection.emit()
	wires.clear()
	wires.untouchable_tiles.clear()
	$Camera2D.position = Vector2.ZERO
	$Camera2D.zoom = Vector2(1, 1)


func _on_gate_dialog_file_selected(path: String) -> void:
	custom_gate_path = path
	wires.load_custom_gate(path)
	highlight = true


func _on_help_button_pressed() -> void:
	helpful_text.visible = not helpful_text.visible


func _on_finish_button_pressed() -> void:
	var start_gates_id: Array[int]
	var end_gates_id: Array[int]
	for gate_id in wires._gates:
		if wires._gates[gate_id].gate == EditorMode.Gate.START:
			start_gates_id.append(gate_id)
		if wires._gates[gate_id].gate == EditorMode.Gate.STOP:
			end_gates_id.append(gate_id)
	var proper_answers: Array[bool]
	match level_selected:
		1:
			await get_tree().create_timer(.25).timeout
			var exit_1: bool = wires._wire_tiles[wires._gate_tiles.find_key(end_gates_id[0])].state
			proper_answers.append(
					true if not exit_1 else false)
			await get_tree().create_timer(.25).timeout
			wire_layer.toggle_start_for_level(wires._gate_tiles.find_key(start_gates_id[0]))
			await wires.queue_cleared
			exit_1 = wires._wire_tiles[wires._gate_tiles.find_key(end_gates_id[0])].state
			proper_answers.append(
					true if exit_1 else false)
		_:
			print("Trying to finish invalid level. How?")
	for correct in proper_answers:
		if not correct:
			print("Źle :(")
			for gate_id in start_gates_id:
				if wires._wire_tiles[wires._gate_tiles.find_key(gate_id)].state == false:
					continue
				wire_layer.toggle_start_for_level(wires._gate_tiles.find_key(gate_id))
			return
	print("Dobrze! :)")
