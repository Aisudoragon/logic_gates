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
signal play_ui_sound()

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


func load_level(id: int, reset: bool = false) -> void:
	if reset:
		finish_button.text = "Wypróbuj rozwiązanie        ▶"
		finish_button.disabled = false

	level_selected = id
	$WiresInterface/SaveButtons/BackButton.visible = false
	$WiresInterface/SaveButtons/BackButton2.visible = true
	$WiresInterface/SaveButtons/SaveButton.visible = false
	$WiresInterface/SaveButtons/ResetLevelButton.visible = true
	$ObjectiveLayer.visible = true
	$WiresInterface/InputOutputView.visible = false
	help_message.resize(3)
	wires.is_sandbox = false
	match level_selected:
		1:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0000_0000)
			help_message[0] = """[center][font_size=28]Proste połączenie[/font_size][/center]

[font_size=14]Tutaj będą wypisane zadania, które należe spełnić:
[ul][color=%s]Połącz oba końce jednym połączeniem[/color][/ul]

Tutaj pojawi się streszczenie zadania. Po naciśnięciu "Wypróbuj rozwiązanie" pojawi się tablica prawdy, która wskaże jak zostało wykonane zadanie.
Poniżej znajduje się również przycisk "Pomoc", który bardziej wprost wskaże co należy zrobić."""
			helpful_text.text = """[font_size=14]Kliknij przycisk "POŁĄCZENIE", przytrzymaj lewy przycisk myszy na jednym końcu i przeciągnij do drugiego końca.[/font_size]"""
		2:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0100_0000)
			help_message[0] = """[center][font_size=28]AND[/font_size][/center]

[font_size=14]Tutaj również prosto. Stwórz układ przy pomocy bramki.
[ul][color=%s]Gdy obydwa wejścia mają sygnał 1, sygnał ma zostać przekazany do wyjścia[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Kliknij przycisk bramki "AND", a następnie wybierz mniejsce na siatce do wstawienia. Następnie połącz wejścia i wyjścia.[/font_size]"""
		3:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_1000_0000)
			help_message[0] = """[center][font_size=28]NOT[/font_size][/center]

[font_size=14]Tutaj również prosto. Stwórz układ przy pomocy bramki.
[ul][color=%s]Gdy obydwa wejścia mają sygnał 1, sygnał ma zostać przekazany do wyjścia[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Kliknij przycisk bramki "NOT", a następnie wybierz mniejsce na siatce do wstawienia. Następnie połącz wejścia i wyjścia.[/font_size]"""
		4:
			wires.level_dimension_limiter(Vector2i(-4, -3), Vector2i(8, 1))
			wires_interface.enable_buttons(0b1100_1100_0000)
			help_message[0] = """[center][font_size=28]NAND[/font_size][/center]

[font_size=14]Połącz obydwie bramki w układ.
[ul][color=%s]Wyjście AND ma być odwrócone.[/color][/ul]
Kolejność bramek ma znaczenie![/font_size]"""
			helpful_text.text = """[font_size=14]Bramki mogą być wstawione tuż obok siebie.[/font_size]"""
		5:
			wires.level_dimension_limiter(Vector2i(-4, -4), Vector2i(7, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			help_message[0] = """[center][font_size=28]OR[/font_size][/center]

[font_size=14][ul][color=%s]Stwórz bramkę OR przy pomocy bramek NAND.[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Jedno wyjście możesz połączyć do kilku wejść.[/font_size]"""
		6:
			wires.level_dimension_limiter(Vector2i(-6, -4), Vector2i(9, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			help_message[0] = """[center][font_size=28]NOR[/font_size][/center]

[font_size=14][ul][color=%s]Stwórz bramkę NOR przy pomocy bramek NAND.[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Spróbuj odwzorować układ z OR. A na końcu odwrócić sygnał.[/font_size]"""
		7, 8:
			wires.level_dimension_limiter(Vector2i(-8, -4), Vector2i(11, 2))
			wires_interface.enable_buttons(0b1100_0010_0000)
			if level_selected == 7:
				help_message[0] = "[center][font_size=28]XOR"
			else:
				help_message[0] = "[center][font_size=28]XNOR"
			help_message[0] += """[/font_size][/center]

[font_size=14][ul][color=%s]Stwórz bramkę XOR przy pomocy bramek NAND.[/color][/ul][/font_size]"""
			if level_selected == 7:
				helpful_text.text = """[font_size=14]XOR jest ciężkim przypadkiem. Wyjście jest pozytywne tylko i wyłącznie kiedy oba wejścia mają różne wartości.[/font_size]"""
			else:
				helpful_text.text = """[font_size=14]Identyczny układ jak w przypadku XOR. Na końcu odwrócony wynik.[/font_size]"""
		9:
			wires.level_dimension_limiter(Vector2i(-5, -6), Vector2i(9, 5))
			wires_interface.enable_buttons(0b1100_0100_0100)
			help_message[0] = """[center][font_size=28]Półpełny sumator[/font_size][/center]

[font_size=14][ul][color=%s]Niech Suma otrzyma sygnał, tylko kiedy jeden z wyjść go wysyła.[/color][/ul]
[ul][color=%s]Niech przeniesienie otrzyma sygnał, tylko kiedy obydwa wyjścia go wysyłają.[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Obydwie bramki, które masz do dyspozycji, idealnie spełniają swoją rolę dla konkretnych celów.[/font_size]"""
		10:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(7, 0))
			wires_interface.enable_buttons(0b1100_0000_0000)
			help_message[0] = """[center][font_size=28]Wiele połączeń[/font_size][/center]

[font_size=14][ul][color=%s]Połącz A do Z[/color][/ul]
[ul][color=%s]Połącz B do Y[/color][/ul]

Skrzyżuj połączenia tak, aby na siebie nie wpływały.[/font_size]"""
			helpful_text.text = """[font_size=14]Jeśli przypadkowo stworzysz rozwidlenie do 3 kierunków. Nie musisz usuwać i rysować ponownie. Wystarczy, że naciśniesz na nie a zamieni się w skrzyżowanie i vice versa![/font_size]"""
		11:
			wires.level_dimension_limiter(Vector2i(-1, -3), Vector2i(6, 1))
			wires_interface.enable_buttons(0b1100_0000_0000)
			help_message[0] = """[center][font_size=28]Rozwidlenia[/font_size][/center]

[font_size=14]Połącz Wejście do:
[ul][color=%s]Wyjścia A[/color][/ul]
[ul][color=%s]Wyjścia C[/color][/ul]
[ul][color=%s]Wyjścia D[/color][/ul]
[b]NIE[/b] łącz Wejścia do:
[ul][color=%s]Wyjścia B[/color][/ul]
[ul][color=%s]Wyjścia E[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14]Połączenia w sąsiedztwie z wejściem/wyjściem automatycznie się połączą.
Jeśli chcesz aby to się nie stało, to daj im trochę odstępu.[/font_size]"""
		12:
			wires.level_dimension_limiter(Vector2i(-4, -6), Vector2i(18, 7))
			wires_interface.enable_buttons(0b1100_0101_0100)
			help_message[0] = """[center][font_size=28]Pełny sumator[/font_size][/center]

[font_size=14][ul][color=%s]Niech Suma otrzyma sygnał, tylko gdy nieparzysta ilość wejść otrzyma sygnał.[/color][/ul]
[ul][color=%s]Niech Przeniesienie otrzyma sygnał, gdy więcej niż 1 wejście otrzyma sygnał.[/color][/ul][/font_size]"""
			helpful_text.text = """[font_size=14][/font_size]"""
		13:
			wires.level_dimension_limiter(Vector2i(-4, -10), Vector2i(25, 10))
			wires_interface.enable_buttons(0b1100_1101_0000)
			help_message[0] = """[center][font_size=28]Multiplekser 4x1[/font_size][/center]

[font_size=14][ul][color=%s]Zbuduj działający multiplexer z 4 wejściami i 2 przełącznikami.[/color][/ul]

Ten zbiór instrukcji przedsstawi jak wejścia mają zostać podłączone:
[center][table=3,center]
[cell border=white padding=1,0,1,5][b] S1 [/b][/cell]
[cell border=white padding=1,0,1,5][b] S2 [/b][/cell]
[cell border=white padding=1,0,1,5][b]Wejście[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]I1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]I2[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]I3[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]I4[/cell]
[/table][/center]

Wygenerowana tablica prawdy będzie bardzo duża, ze względu na dużą ilość wejść.[/font_size]"""
			helpful_text.text = """[font_size=14]Zasada jest taka sama jak przy mniejszym multiplekserze. Należy rozszerzyć poprzedni schemat by uwzględnić dodatkowe wejścia.[/font_size]"""
		14:
			wires.level_dimension_limiter(Vector2i(-2, -3), Vector2i(18, 6))
			wires_interface.enable_buttons(0b1100_1101_0000)
			help_message[0] = """[center][font_size=28]Multiplekser 2x1[/font_size][/center]

[font_size=14][ul][color=%s]Zbuduj działający multiplekser z dwoma wejściami.[/color][/ul]

Wejścia zostały skrócone:
Wejście 1 - I1
Wejście 2 - I2
Przełącznik - S1

Kiedy przełącznik jest wyłączony, ma odbierać sygnał z S1.[/font_size]"""
			helpful_text.text = """[font_size=14]Na danym stanie przełącznika, skup się na odbieraniu sygnału tylko z tego wejścia.[/font_size]"""
		101:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0100_0000)
			help_message[0] = """[center][font_size=28]Koniunkcja[/font_size][/center]

[font_size=14][ul][color=%s]Dokończ układ[/color][/ul]

Należy wstawić nie tylko samą bramkę, ale również dokończyć połączenia.[/font_size]"""
			helpful_text.text = """[font_size=14]Jeśli chcesz wstawić dany element. Kliknij przycisk myszy na któryś przycisk na dole. Następnie naciśnij w dostępnym miejscu na siatce. W przypadku przwodu: przeciągnij i puść lewy przycisk myszy.[/font_size]"""
		102:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_0001_0000)
			help_message[0] = """[center][font_size=28]Dysjunkcja[/font_size][/center]

[font_size=14][ul][color=%s]Dokończ układ[/color][/ul]

Należy wstawić nie tylko samą bramkę, ale również dokończyć połączenia.[/font_size]"""
			helpful_text.text = """[font_size=14]Jeśli chcesz wstawić dany element. Kliknij przycisk myszy na któryś przycisk na dole. Następnie naciśnij w dostępnym miejscu na siatce. W przypadku przwodu: przeciągnij i puść lewy przycisk myszy.[/font_size]"""
		103:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(6, 1))
			wires_interface.enable_buttons(0b1100_1000_0000)
			help_message[0] = """[center][font_size=28]Negacja[/font_size][/center]

[font_size=14][ul][color=%s]Dokończ układ[/color][/ul]

Należy wstawić nie tylko samą bramkę, ale również dokończyć połączenia.[/font_size]"""
			helpful_text.text = """[font_size=14]Jeśli chcesz wstawić dany element. Kliknij przycisk myszy na któryś przycisk na dole. Następnie naciśnij w dostępnym miejscu na siatce. W przypadku przwodu: przeciągnij i puść lewy przycisk myszy.[/font_size]"""
		104:
			wires.level_dimension_limiter(Vector2i(-2, -3), Vector2i(8, 1))
			wires_interface.enable_buttons(0b1100_0101_0000)
			help_message[0] = """[center][font_size=28]Kilka bramek[/font_size][/center]

[font_size=14][ul][color=%s]Dokończ układ wedle wzoru na wyjściu[/color][/ul]

Pamiętaj o wiązaniu:
Negacja > koniunkcja > dysjunkcja.[/font_size]"""
			helpful_text.text = """[font_size=14]Wiązania traktuj jak kolejność bramek po których przejdzie sygnał.[/font_size]"""
		105:
			wires.level_dimension_limiter(Vector2i(-3, -3), Vector2i(7, 1))
			wires_interface.enable_buttons(0b1100_1000_1000)
			help_message[0] = """[center][font_size=28]Różne wejścia[/font_size][/center]

[font_size=14][ul][color=%s]Złóż układ wedle wzoru na wyjściu, używając NOT i NOR.[/color][/ul]

NOR na wyjściu ma 1 tylko, gdy obydwa wejścia mają 0[/font_size]"""
			helpful_text.text = """[font_size=14]NOT jest dany nie bez powodu. Potrzeba aby specyficznie x wysyłał 1 aby wyjście również wysyłało 1. W każdym innym przypadku 0.[/font_size]"""
		106:
			wires.level_dimension_limiter(Vector2i(-3, -6), Vector2i(15, 4))
			wires_interface.enable_buttons(0b1100_1101_0000)
			help_message[0] = """[center][font_size=28]Zrobienie XNOR[/font_size][/center]

[font_size=14][ul][color=%s]Złóż układ imitujący działanie XNOR.[/color][/ul]

Na wyjściu ma być 1 tylko, gdy obydwa wejścia mają tą samą wartość.[/font_size]"""
			helpful_text.text = """[font_size=14]Jeśli w trakcie skrzyżowania połączenia połączyły się ze sobą, to wystarczy że na nie klikniesz i odseparuje połączenia. Tak samo w drugą stronę.

Masz dużo przestrzeni. Dobrze jest za wziąć się krokami.
Gdy x i y mają 0, po złączeniu ma być 1. Gdy x i y mają 1, po złączeniu również ma być 1.[/font_size]"""
		_:
			print("Invalid level selected. How?")
			wires.level_dimension_limiter(Vector2i.ZERO, Vector2i.ZERO)
			wires_interface.enable_buttons(0b0000_0000_0000)

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
	if FileAccess.file_exists(file_path) and not reset:
		wires.load_file(file_path)


func reset_playground_state() -> void:
	$Camera2D.position = Vector2.ZERO
	$Camera2D.zoom = Vector2(1, 1)
	wires_interface.enable_buttons(0b1111_1111_1111)
	mode_selected = EditorMode.Mode.SELECT
	gate_selected = EditorMode.Gate.AND
	wires.clear()
	$WiresInterface/SaveButtons.save_path = ""

	level_selected = 0
	wires.untouchable_tiles.clear()
	finish_button.disabled = false
	finish_button.text = "Wypróbuj rozwiązanie        ▶"
	$WiresInterface/SaveButtons/BackButton.visible = true
	$WiresInterface/SaveButtons/BackButton2.visible = false
	$WiresInterface/SaveButtons/SaveButton.visible = true
	$WiresInterface/SaveButtons/ResetLevelButton.visible = false
	$ObjectiveLayer.visible = false
	$WiresInterface/InputOutputView.visible = true



func _on_wires_interface_mode_selected(mode: EditorMode.Mode, gate: EditorMode.Gate) -> void:
	mode_selected = mode
	gate_selected = gate

	if mode == EditorMode.Mode.SELECT:
		highlight_layer.clear()
	if gate == EditorMode.Gate.CUSTOM and $WiresInterface/GateDialog.visible == false:
		highlight = false
		$WiresInterface/GateDialog.visible = true

		# TODO dodać wczytywanie listy tutaj
		var directory: DirAccess = SaveProgress.open_customs_directory()
		var files: PackedStringArray = directory.get_files()
		for file in files:
			var new_button := CustomGateButton.new(file)
			new_button.load_file.connect(_on_gate_dialog_file_selected)
			$WiresInterface/GateDialog/Panel/ScrollContainer/MarginContainer/VBoxContainer.add_child(new_button)
	else:
		highlight = true
		$WiresInterface/GateDialog.visible = false
		for n in $WiresInterface/GateDialog/Panel/ScrollContainer/MarginContainer/VBoxContainer.get_children():
			n.queue_free()

	play_ui_sound.emit()


func _on_back_button_pressed() -> void:
	change_scene_main_menu.emit()
	reset_playground_state()


func _on_back_button_2_pressed() -> void:
	change_scene_level_selection.emit()
	reset_playground_state()


func _on_gate_dialog_file_selected(path: String) -> void:
	custom_gate_path = "%s/%s" % [Filepaths.custom_gates_directory, path]
	wires.load_custom_gate(custom_gate_path)
	highlight = true
	$WiresInterface/GateDialog.visible = false
	for n in $WiresInterface/GateDialog/Panel/ScrollContainer/MarginContainer/VBoxContainer.get_children():
		n.queue_free()

	play_ui_sound.emit()


func _on_help_button_pressed() -> void:
	helpful_text.visible = not helpful_text.visible

	play_ui_sound.emit()


func _on_finish_button_pressed() -> void:
	play_ui_sound.emit()

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
		if level_selected == 13:
			await get_tree().create_timer(0.1).timeout
		else:
			await get_tree().create_timer(0.85).timeout

		for gate in range(start_gates.size()):
			wires.set_output(start_gates[gate], start >> gate & 1)
			help_message[2] += "[cell border=white]%d[/cell]" % (start >> gate & 1)
			objective_text.text = buffer_objective + help_message[2]
		await wires.queue_cleared

		if not visible:
			return

		for gate in start_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
		for gate in end_gates:
			truth_table_content.append(wires._wire_tiles[gate].state)
			guesses.append(wires._wire_tiles[gate].state)
			help_message[2] += "[cell border=white]%d[/cell]" % int(wires._wire_tiles[gate].state)
			objective_text.text = buffer_objective + help_message[2]

	buffer_objective = buffer_objective + help_message[2]

	match level_selected:
		101:
			if not guesses[0] and not guesses[1] and not guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_101 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(101))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		102:
			if not guesses[0] and guesses[1] and guesses[2] and guesses[3]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_102 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(102))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		103:
			if guesses[0] and not guesses[1]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_103 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(103))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		104:
			if not guesses[0] and guesses[1] and not guesses[2] and guesses[3] and not guesses[4] and guesses[5] and guesses[6] and guesses[7]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_104 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(104))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		105:
			if guesses[1] and not guesses[0] and not guesses[3] and not guesses[2]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_105 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(105))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		106:
			if guesses[0] and guesses[3] and not guesses[1] and not guesses[2]:
				finish_button.text = "Ukończono!"
				objective_text.text = buffer_objective % "green"
				SaveProgress.level_106 = true
				SaveProgress.update_save_file()
				SaveProgress.ensure_directory_available()
				wires.save_circuit(Filepaths.levels_dir_path(106))
			else:
				finish_button.text = "Wypróbuj rozwiązanie        ▶"
				objective_text.text = buffer_objective % "red"
		_:
			print("Trying to finish invalid level. How?")
			finish_button.text = "Wypróbuj rozwiązanie        ▶"
	if not finish_button.text == "Ukończono!":
		$LevelObjectiveAudioPlayer.stream = AudioStreamOggVorbis.load_from_file("res://assets/Sounds/error_006.ogg")
		$LevelObjectiveAudioPlayer.play()
		for gate in start_gates:
			wires.set_output(gate, false)
			await wires.queue_cleared

		finish_button.disabled = false
		return
	else:
		$LevelObjectiveAudioPlayer.stream = AudioStreamOggVorbis.load_from_file("res://assets/Sounds/confirmation_002.ogg")
		$LevelObjectiveAudioPlayer.play()

	finish_button.disabled = false




func send_signal_for_ui_sound() -> void:
	play_ui_sound.emit()


func _on_reset_level_button_pressed() -> void:
	wires.clear()
	load_level(level_selected, true)

	play_ui_sound.emit()
