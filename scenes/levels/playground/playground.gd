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

#Camera stuff
@export var camera: Camera2D
@export var zoomSpeed: float = 0.025
@export var camera_speed: float = 1000.0
var direction := Vector2.ZERO

var zoomMin: float = 0.05
var zoomMax: float = 2.0
var dragSensitivity: float = 1.0


func _process(delta: float) -> void:
	wires_interface.update_queue_size(wires._callable_queue.size())
	wires_interface.visible = visible

	camera.anchor_mode = int(visible)

	camera.position += camera_speed * direction / camera.zoom * delta
	if not wires.is_sandbox:
		var dimenions: Array[Vector2i] = wires.dimension_limits
		if camera.position.x < dimenions[0].x * 64:
			camera.position.x = dimenions[0].x * 64
		elif camera.position.x > dimenions[1].x * 64:
			camera.position.x = dimenions[1].x * 64
		if camera.position.y < dimenions[0].y * 64:
			camera.position.y = dimenions[0].y * 64
		elif camera.position.y > dimenions[1].y * 64:
			camera.position.y = dimenions[1].y * 64
	if direction:
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	# Camera
	if camera.anchor_mode == 1:
		if event is InputEventMouseButton and event.is_pressed():
			var event_mb: InputEventMouseButton = event
			if event_mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom += Vector2(zoomSpeed, zoomSpeed)
			elif event_mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom -= Vector2(zoomSpeed, zoomSpeed)
			camera.zoom = clamp(camera.zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))

		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			var event_mm: InputEventMouseMotion = event
			camera.position -= event_mm.relative * dragSensitivity / camera.zoom

		direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

	# Editor
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
	level_selected = id
	$WiresInterface/SaveButtons/BackButton.visible = false
	$WiresInterface/SaveButtons/BackButton2.visible = true
	$WiresInterface/SaveButtons/SaveButton.visible = false
	$WiresInterface/SaveButtons/ResetLevelButton.visible = true
	$ObjectiveLayer.visible = true
	help_message.resize(3)
	wires.is_sandbox = false
	match level_selected:
		1:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0000_0000)
			help_message[0] = """[center][font_size=28]Zadanie 1[/font_size][/center]

Na początek coś prostego.
[ul][color=%s]Połącz oba końce w jeden kabel[/color][/ul]

Na końcu każdego takiego streszczenia pojawi się tablica prawdy, która zostanie uzupełniona po wypróbowaniu rozwiązania.
Przyszłe zadania [i]mogą[/i] wymagać, aby była wygenerowana w konkretny sposób."""
			helpful_text.text = """Kliknij przycisk "KABEL", przytrzymaj lewy przycisk myszy na jednym końcu i przeciągnij do drugiego końca."""
		2:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0100_0000)
			help_message[0] = """[center][font_size=28]Zadanie 2.1[/font_size][/center]

Tutaj również prosto. Stwórz układ przy pomocy bramki.
[ul][color=%s]Gdy obydwa wejścia mają sygnał 1, sygnał ma zostać przekazany do wyjścia[/color][/ul]

Możesz zauważyć, że po wykonaniu poprawnie zadania, zostanie wygenerowana tablica prawdy taka sama jak w rozpisie lekcji."""
			helpful_text.text = """Kliknij przycisk bramki "AND", a następnie wybierz mniejsce na siatce do wstawienia. Następnie połącz wejścia i wyjścia."""
		3:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_1000_0000)
			help_message[0] = """[center][font_size=28]Zadanie 2.2[/font_size][/center]

Tutaj również prosto. Stwórz układ przy pomocy bramki.
[ul][color=%s]Gdy obydwa wejścia mają sygnał 1, sygnał ma zostać przekazany do wyjścia[/color][/ul]"""
			helpful_text.text = """Kliknij przycisk bramki "AND", a następnie wybierz mniejsce na siatce do wstawienia. Następnie połącz wejścia i wyjścia."""
		4:
			wires.level_dimension_limiter(Vector2i(-4, -3), Vector2i(8, 1))
			wires_interface.enable_buttons(0b1100_1100_0000)
			help_message[0] = ""
			helpful_text.text = ""
		5:
			wires.level_dimension_limiter(Vector2i(-4, -4), Vector2i(7, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			help_message[0] = ""
			helpful_text.text = ""
		6:
			wires.level_dimension_limiter(Vector2i(-6, -4), Vector2i(9, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			help_message[0] = ""
			helpful_text.text = ""
		7, 8:
			wires.level_dimension_limiter(Vector2i(-8, -4), Vector2i(11, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			help_message[0] = ""
			helpful_text.text = ""
		9:
			wires.level_dimension_limiter(Vector2i(-5, -6), Vector2i(9, 5))
			wires_interface.enable_buttons(0b1111_1111_1000)
			help_message[0] = ""
			helpful_text.text = ""
		_:
			print("Invalid level selected. How?")

	wires.load_file(Filepaths.file_path_to_level(level_selected))

	wires.untouchable_tiles = wires._wire_tiles.keys()
	for tile in wires._gate_tiles:
		if wires.untouchable_tiles.has(tile):
			continue
		wires.untouchable_tiles.append(tile)
	for tile in wires._wire_crossing_tiles:
		if wires.untouchable_tiles.has(tile):
			continue
		wires.untouchable_tiles.append(tile)

	var table_headers: Array[String]
	for gate in wires._gates:
		if wires._gates[gate].gate == EditorMode.Gate.START:
			table_headers.append(" " + wires._gates[gate].display_name + " ")
		if wires._gates[gate].gate == EditorMode.Gate.STOP:
			table_headers.append(" " + wires._gates[gate].display_name + " ")
	help_message[1] = "\n\n[center][table=%d,center]" % table_headers.size()
	for cell in table_headers:
		help_message[1] += "[cell border=white][b]%s[/b][/cell]" % cell

	objective_text.text = help_message[0] + help_message[1] % "red"

	var file_path: String = Filepaths.levels_dir_path(level_selected)
	if FileAccess.file_exists(file_path):
		wires.load_file(file_path)


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
	$WiresInterface/SaveButtons/ResetLevelButton.visible = false
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

	finish_button.text = "Testowanie..."
	finish_button.disabled = true

	var guesses: Array[bool]
	var truth_table_content: Array[bool]
	var buffer_objective: String = help_message[0] + help_message[1]
	help_message[2] = ""

	for start in range(2 ** start_gates.size()):
		await get_tree().create_timer(.25).timeout

		for gate in range(start_gates.size() - 1, -1, -1):
			wires.set_output(start_gates[gate], start >> gate & 1)
			help_message[2] += "[cell border=white]%d[/cell]" % (start >> gate & 1)
			objective_text.text = buffer_objective + help_message[2]
		await wires.queue_cleared

		for gate in start_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
		for gate in end_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
			guesses.append(wires._wire_tiles[gate].state)
			help_message[2] += "[cell border=white]%d[/cell]" % int(wires._wire_tiles[gate].state)
			objective_text.text = buffer_objective + help_message[2]

	buffer_objective = buffer_objective + help_message[2]

	match level_selected:
		1:
			if not guesses[0] and guesses[1]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_1 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(1))
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		2:
			if not guesses[0] and not guesses[1] and not guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		3:
			if guesses[0] and not guesses[1]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		4:
			if guesses[0] and guesses[1] and guesses[2] and not guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		5:
			if not guesses[0] and guesses[1] and guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		6:
			if guesses[0] and not guesses[1] and not guesses[2] and not guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		7:
			if not guesses[0] and guesses[1] and guesses[2] and not guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		8:
			if guesses[0] and not guesses[1] and not guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		9:
			if guesses[0] and not guesses[1] and not guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
			else:
				finish_button.text = "Wypróbuj rozwiązanie"
				finish_button.disabled = false
				objective_text.text = buffer_objective % "red"
		_:
			print("Trying to finish invalid level. How?")
	if not finish_button.text == "Ukończono!":
		for gate in start_gates:
			wires.set_output(gate, false)
		return


func _on_reset_level_button_pressed() -> void:
	wires.clear()
	wires.load_file(Filepaths.file_path_to_level(level_selected))
