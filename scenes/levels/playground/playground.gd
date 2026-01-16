class_name Playground extends Node2D

@export var wire_layer: WireLayer
@export var highlight_layer: HighlightLayer
@export var wires: Wires
@export var wires_interface: WiresInterface
@export var objective_text: RichTextLabel
@export var helpful_text: RichTextLabel
@export var finish_button: Button

signal change_scene_main_menu()
signal change_scene_level_selection()

var mode_selected: EditorMode.Mode = EditorMode.Mode.SELECT
var gate_selected: EditorMode.Gate = EditorMode.Gate.AND
var highlight := false
var custom_gate_path: String

var help_message: Array[String]
var level_selected: int


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
						wires.toggle_output()
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
	help_message.resize(4)
	match id:
		1:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires.untouchable_tiles = [Vector2i(1, -1), Vector2i(5, -1)]
			wires.is_sandbox = false
			level_selected = 1
			help_message[0] = """[center][font_size=28]Zadanie 1[/font_size][/center]

Na początek coś prostego.
[ul][color=red]Połącz oba końce w jeden kabel[/color][/ul]

Na końcu każdego takiego streszczenia pojawi się tablica prawdy, która zostanie uzupełniona po wypróbowaniu rozwiązania."""
			helpful_text.text = """Kliknij przycisk "KABEL", przytrzymaj lewy przycisk myszy na jednym końcu i przeciągnij do drugiego końca."""
			wires_interface.enable_buttons(0b1100_0000_0000)
			wires.load_file("res://scenes/levels/level_1.json")
		2:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires.untouchable_tiles = [Vector2i(-1, -1), Vector2i(5, -1)]
			wires.is_sandbox = false
			level_selected = 2
			wires_interface.enable_buttons(0b1100_1000_0000)
			wires.load_file("res://scenes/levels/level_2.json")
		_:
			print("Invalid level selected. How?")

	var table_headers: Array[String]
	for gate in wires._gates:
		if wires._gates[gate].gate == EditorMode.Gate.START:
			# TODO wykorzystać nazwy wejść i wyjść
			table_headers.append("a")
		if wires._gates[gate].gate == EditorMode.Gate.STOP:
			table_headers.append("wyjście")
	help_message[1] = "\n\n[center][table=%d,center]" % table_headers.size()
	for cell in table_headers:
		help_message[1] = help_message[1] + "[cell border=white][b]%s[/b][/cell]" % cell
	help_message[3] = "[/table][/center]"

	objective_text.text = help_message[0] + help_message[1] + help_message[3]


func reset_playground_state() -> void:
	$Camera2D.position = Vector2.ZERO
	$Camera2D.zoom = Vector2(1, 1)
	wires_interface.enable_buttons(0b1111_1111_1111)
	mode_selected = EditorMode.Mode.SELECT
	gate_selected = EditorMode.Gate.AND
	wires.clear()

	level_selected = 0
	wires.untouchable_tiles.clear()
	finish_button.disabled = false
	finish_button.text = "Wypróbuj rozwiązanie"
	$WiresInterface/SaveButtons/BackButton.visible = true
	$WiresInterface/SaveButtons/BackButton2.visible = false
	$WiresInterface/SaveButtons/SaveButton.visible = true
	$ObjectiveLayer.visible = false



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
	reset_playground_state()


func _on_back_button_2_pressed() -> void:
	change_scene_level_selection.emit()
	reset_playground_state()


func _on_gate_dialog_file_selected(path: String) -> void:
	custom_gate_path = path
	wires.load_custom_gate(path)
	highlight = true


func _on_help_button_pressed() -> void:
	helpful_text.visible = not helpful_text.visible


func _on_finish_button_pressed() -> void:
	var start_gates: Array[Vector2i]
	var end_gates: Array[Vector2i]
	for gate_id in wires._gates:
		if wires._gates[gate_id].gate == EditorMode.Gate.START:
			start_gates.append(wires._gate_tiles.find_key(gate_id))
		if wires._gates[gate_id].gate == EditorMode.Gate.STOP:
			end_gates.append(wires._gate_tiles.find_key(gate_id))

	help_message[2] = ""

	finish_button.text = "Testowanie..."
	finish_button.disabled = true

	var guesses: Array[bool]
	var truth_table_content: Array[bool]

	for start in range(2 ** start_gates.size()):
		await get_tree().create_timer(.25).timeout

		for gate in range(start_gates.size() - 1, -1, -1):
			wires.set_output(start_gates[gate], start >> gate & 1)
			help_message[2] = help_message[2] + "[cell border=white]%d[/cell]" % (start >> gate & 1)
			objective_text.text = help_message[0] + help_message[1] + help_message[2] + help_message[3]
		await wires.queue_cleared

		for gate in start_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
		for gate in end_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
			guesses.append(wires._wire_tiles[gate].state)
			help_message[2] = help_message[2] + "[cell border=white]%d[/cell]" % int(wires._wire_tiles[gate].state)
			objective_text.text = help_message[0] + help_message[1] + help_message[2] + help_message[3]
	print(truth_table_content)

	match level_selected:
		1:
			if guesses[0] == false and guesses[1] == true:
				finish_button.text = "Ukończono!"
				help_message[0] = """[center][font_size=28]Zadanie 1[/font_size][/center]

Na początek coś prostego.
[ul][color=green]Połącz oba końce w jeden kabel[/color][/ul]

Na końcu każdego takiego streszczenia pojawi się tablica prawdy, która zostanie uzupełniona po wypróbowaniu rozwiązania."""
				objective_text.text = help_message[0] + help_message[1] + help_message[2] + help_message[3]
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
		_:
			print("Trying to finish invalid level. How?")
	if not finish_button.text == "Ukończono!":
		for gate in start_gates:
			wires.set_output(gate, false)
		return
	print("Dobrze!")
	match level_selected:
		1:
			SaveProgress.level_1 = true
			SaveProgress.update_save_file()
