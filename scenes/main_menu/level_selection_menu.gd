class_name LevelSelectionMenu extends Control

signal change_scene_main_menu()
signal change_scene_level_selected(id: int)
signal play_ui_sound()

# Dialogue [Speaker, sentence], [Speaker, sentence]
var sentences: Array[Array] = [
	# Postacie:
		# Ja
		# Kowalski - Szef
		# Kwiatkowski (Marcin)
	[
		["Szef", "Bardzo się cieszymy, że dołączył Pan do naszego zespołu!"],
		["Szef", "Zajmę się się teraz formalnościami. Dla Pana został przydzielony nasz inżynier Kwiatkowski."],
		["Szef", "W tym czasie proszę udać się na swoje stanowisko, a Pan Kwiatkowski niedługo przybędzie."],
		["Ja", "[i]Po kilku minutach...[/i]"],
		["Kwiatkowski", "Cześć! Marcin jestem. Przysłał mnie szef."],
		["Ja", "Mateusz, miło mi."],
		["Kwiatkowski", "Szef mi powiedział, że mamy nowego pracownika. Fajnie jest zobaczyć nową twarz."],
		["Ja", "I równie fajnie jest pracować w nowej firmie. Zmiana otoczenia wyjdzie mi na dobre."],
		["Kwiatkowski", "Oby Ci się spodobało tutaj! Jak chcesz to na przerwie będzie można się zgadać, albo popoznawać inne nowe twarze."],
		["Kwiatkowski", "No, to teraz przejdźmy do obowiązków."],
		["Kwiatkowski", "Najważniejsze pytanie: jak dużo wiesz o układach cyfrowych?"],
		["Ja", "No... W sumie to niewiele."],
		["Kwiatkowski", "Niewiele jak bardzo?"],
		["Ja", "Na pewno przyda mi się odświeżenie pamięci."],
		["Kwiatkowski", "Rozumiem. To co? Może być rozpoczęcie od podstaw?"],
		["Ja", "A jest taka możliwość?"],
		["Kwiatkowski", "Oczywiście! Jesteśmy przygotowani na takie wypadki!"],
		["Kwiatkowski", "Oto nasz program szkoleniowy. Idealny nie jest i ma swoje lata, ale pomaga załatwić robotę."],
		["Kwiatkowski", "Na początek kliknij na pierwszy element z listy po lewej. Wtedy na prawej części zobaczysz opis, wyjaśnienia i tak dalej."],
		["Kwiatkowski", "Na samym początku trzeba zrozumieć czym jest algebra Boole'a."],
		["Ja", "Oby moja nauka nie była bólem dla Ciebie."],
		["Kwiatkowski", "Już Cię lubię!"],
		["Kwiatkowski", "Po tym jak przejrzysz materiały, są przygotowane jeszcze testy z wiedzy, żeby sprawdzić czy na pewno zapamiętałeś temat."],
		["Ja", "[i]Elementy dydaktyczne są oznaczone przyciskami z białym tekstem.[/i]"],
		["Ja", "[i]Testy wiedzy są oznaczone przyciskami z pomarańczowym tekstem.[/i]"],
		["Ja", "[i]Dialogi można powtórzyć, klikając na przyciski w liście z żółtym tekstem.[/i]"],
	],
	[
		["Marcin", "Dobra. Podstawy podstaw masz ogarnięte."],
		["Marcin", "Zapomnieliśmy to dodać w programie, więc słuchaj uważnie:"],
		["Marcin", "Każde z tych spójników ma wiązanie."],
		["Marcin", "Negacja wiąże najmocniej. Koniunkcja słabiej, a Dysjunkcja wiąże najsłabiej."],
		["Marcin", "Możesz to porównać jak do kolejności wykonywania działań."],
		["Marcin", "Dysjunkcję możesz potraktować jak dodawanie/odejmowanie. Koniunkcję jak mnożenie/dzielenie, a negację jak potęgowanie."],
		["Marcin", "Czyli, jeśli masz dysjunkcję i negację w działaniu. To negacja jest pierwsza w wykonywaniu działania. Oczywiście można to zmienić przy pomocy nawiasów."],
		["Marcin", "Zobaczę jak Ci pójdzie."],
	],
	[
		["Marcin", "No, no! Poznałeś właśnie działanie wszystkich bramek!"],
		["Marcin", "Teraz pora na więcej zadań aby utrwawiła Ci się ta wiedza."],
	],
	[
		["Marcin", "Świetnie sobie ze wszystkim poradziłeś!"],
		["Marcin", "Jest już późno więc lepiej się już zbierajmy."],
		["Marcin", "Pamiętaj, że w każdej chwili możesz skorzystać z trybu piaskownicy w naszym programie. Masz tam największą swobodę i możesz robić co chcesz. Eksperymentować, czy spróbować zoptymalizować jakis obwód."],
	]
]
# Dialogue_X, sentences
var dialogues: Dictionary[StringName, Array] = {
	&"dialogue_1": sentences[0],
	&"dialogue_2": sentences[1],
	&"dialogue_3": sentences[2],
	&"dialogue_4": sentences[3],
}
var current_dialogue: Array

var lesson_selected: int = 0
@export var lessonExplanation: RichTextLabel
@export var proceedButton: Button

@onready var level_button_101: Button = %LevelButton101
@onready var level_button_102: Button = %LevelButton102
@onready var level_button_103: Button = %LevelButton103
@onready var level_button_104: Button = %LevelButton104
@onready var level_button_105: Button = %LevelButton105
@onready var level_button_106: Button = %LevelButton106
@onready var learn_button_3: Button = %LearnButton3
@onready var learn_button_4: Button = %LearnButton4
@onready var dialogue_button_2: Button = %DialogueButton2
@onready var dialogue_button_3: Button = %DialogueButton3


@onready var speaker_name: RichTextLabel = $DialogueBox/ColorRect/MarginContainer/VBoxContainer/MarginContainer2/SpeakerName
@onready var speaker_text: RichTextLabel = $DialogueBox/ColorRect/MarginContainer/VBoxContainer/MarginContainer/SpeakerText
@onready var speaker_image: TextureRect = $DialogueBox/SpeakerImage


func _unhandled_key_input(event: InputEvent) -> void:
	if not ($DialogueBox as ColorRect).visible or not event.is_action_pressed(&"special"):
		return

	dialogue_advance()


func introduction_visibility(visibility: bool) -> void:
	if visibility:
		start_conversation(&"dialogue_1")
		SaveProgress.dialogue_1 = true
		SaveProgress.update_save_file()


func start_conversation(dialogue: StringName) -> void:
	($DialogueBox as ColorRect).visible = true

	current_dialogue = dialogues[dialogue].duplicate(true)
	var this_sentence: Array = current_dialogue.pop_front()
	speaker_name.text = this_sentence[0]
	speaker_text.text = this_sentence[1]
	speaker_image.texture = pick_image_for_dialogue(this_sentence[0])


func dialogue_advance() -> void:
	if current_dialogue.is_empty():
		($DialogueBox as ColorRect).visible = false
		return

	var this_sentence: Array = current_dialogue.pop_front()
	speaker_name.text = this_sentence[0]
	speaker_text.text = this_sentence[1]

	if this_sentence[0] == "Ja":
		speaker_image.texture = ImageTexture.new()
	else:
		speaker_image.texture = pick_image_for_dialogue(this_sentence[0])


func pick_image_for_dialogue(speaker: String) -> CompressedTexture2D:
	return load("res://assets/resources/textures/dialogue_avatars/%s.png" % speaker)


func _on_back_pressed() -> void:
	change_scene_main_menu.emit()
	lessonExplanation.text = "[center]Wybierz zadanie, aby lepiej się z nim zapoznać.[/center]"
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	proceedButton.visible = false


func _on_learn_button_1_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Algebra Boole'a[/center][/font_size]
[hr]
Na sam początek przypomnijmy w skrócie algebrę Boole'a.

[ul]Dana zmienna (np. [i]x[/i]) może mieć tylko jedną z dwóch wartości:
[ul]1 - inaczej prawda (oznaczone kolorem białym wzdłuż połączenia)[/ul]
[ul]0 - inaczej fałsz (oznaczone kolorem ciemnoszarym wzdłuż połączenia)[/ul]
[/ul]

[center][img]res://assets/resources/textures/dialogue_images/dialogue_1_1.png[/img][/center]"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = false

	play_ui_sound.emit()


func _on_level_button_101_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Koniunkcja[/center][/font_size]
[hr]
Koniunkcja (i, iloczyn logiczny) jest spójnikiem dwuargumentowym.
[font_size=40][center]x ∧ y[/center][/font_size]
Oznacza to, że wyjście jest 1 (prawda) tylko i wyłącznie, jeśli obydwa wejścia też są 1 (prawda).
W przeciwnym wypadku wyjście jest 0 (fałsz).

Bramka AND [img=48]res://assets/resources/textures/gates/and_gate.png[/img] wykonuje tę operację.

Można przedstawić następująco:
0 ∧ 0 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_1.png[/img]
0 ∧ 1 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_2.png[/img]
1 ∧ 0 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_3.png[/img]
1 ∧ 1 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_4.png[/img]

Więc biorąc te rzeczy pod uwagę można stworzyć tablicę prawdy:

[center][table=3]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]x ∧ y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[/table][/center]

Sprawdzisz bramkę w praktyce.




"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 101

	play_ui_sound.emit()


func _on_lesson_button_102_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Dysjunkcja[/center][/font_size]
[hr]
Dysjunkcja (lub, suma logiczna) jest spójnikiem dwuargumentowym.
[font_size=40][center]x ∨ y[/center][/font_size]
Oznacza to, że wyjście jest 1 (prawda), jeśli chociaż jedno wejście jest 1 (prawda).
W przeciwnym wypadku wyjście jest 0 (fałsz).

Bramka AND [img=48]res://assets/resources/textures/gates/or_gate.png[/img] wykonuje tę operację.

Można przedstawić następująco:
0 ∨ 0 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_5.png[/img]
0 ∨ 1 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_6.png[/img]
1 ∨ 0 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_7.png[/img]
1 ∨ 1 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_8.png[/img]

Więc biorąc te rzeczy pod uwagę można stworzyć tablicę prawdy:

[center][table=3]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]x ∨ y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[/table][/center]

Sprawdzisz bramkę w praktyce.




"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 102

	play_ui_sound.emit()


func _on_lesson_button_2_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka AND   [img=64]res://assets/resources/textures/gates/and_gate.png[/img][/center][/font_size]
[hr]
Pora skorzystać z pierwszej bramki, AND (i).
[i]Jeśli nie wiesz jak działają bramki logiczne to ta lekcja wprowadzi Cię w trybie ekspresowym w ich działanie.[/i]

Posiada ona dwa wejścia i jedno wyjście. Działa tak samo jak koniunkcja w algebrze Boole'a, tzn. Że na wejściu, jeśli obydwa sygnały są pozytywne, to tylko wtedy na wyjściu również będzie pozytywny.
Można to przedstawić na tablicy prawdy w taki sposób:

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=2227]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table][/center]

[i]A, oraz B są wejściami do bramki. Wyjście mówi samo za siebie.[/i]

[hr]
Następne kilka poradników wprowadzą Cię po kolei w każdą, dostępną bramkę logiczną. W tej lekcji, zobaczysz jak się taką wstawia do układu, oraz jak ją połączyć."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 2

	play_ui_sound.emit()


func _on_lesson_button_3_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka NOT   [img=64]res://assets/resources/textures/not_gate_button.png[/img][/center][/font_size]
[hr]
Następna bramka, NOT (nie).

Ta bramka posiada jedno wejście i jedno wyjście. Ta bramka służy do odwrócenia sygnału. To znaczy, jeśli na wejściu jest sygnał 0, to na wyjściu jest sygnał 1 i na odwrót.

[i]Tablica prawdy będzie przedstawiona w poziomie po poprawnym wykonaniu.[/i]

[hr]
W tej lekcji sprawdzisz działanie bramki NOT."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 3

	play_ui_sound.emit()


func _on_lesson_button_4_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka NAND   [img=64]res://assets/resources/textures/gates/nand_gate.png[/img][/center][/font_size]
[hr]
W tym zadaniu użyjesz kombinacji dwóch wcześniejszych bramek.

Nazwa NAND jest połączeniem [b]N[/b]OT, oraz [b]AND[/b]. Z tej nazwy można wywnioskować, że bramka ma odwrotny efekt od bramki AND. To znaczy, że wyjście będzie pozytywne tylko wtedy gdy obydwa wejścia NIE będą pozytywne.

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=2227]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table] Oraz odwrócenie wyniku: [table=1,center]
[cell border=white padding=1,0,1,5][b][char=AC](A[char=2227]B)[/b][/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[/table][/center]

[hr]
Tutaj połączysz ze sobą bramki. Takie połączenia będą rosnąć z kolejnymi poziomami."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 4

	play_ui_sound.emit()


func _on_lesson_button_5_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka OR   [img=64]res://assets/resources/textures/gates/or_gate.png[/img][/center][/font_size]
[hr]
Teraz znając działanie NAND, zrozumienie następnych bramek będzie wymagać stworzenia układów, w których do użycia będzie dostępna tylko i wyłącznie NAND.

Tak więc pierwszą bramkę, którą należy skonstruować to OR. Wyjście z tej bramki jest pozytywne, jeśli chociaż jedno wejście jest pozytywne.
Tablica prawdy dla tej bramki wygląda następująco:

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=2228]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table][/center]

[hr]
Należy stworzyć układ, który stworzy powyższą tablicę."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 5

	play_ui_sound.emit()


func _on_lesson_button_6_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka NOR   [img=64]res://assets/resources/textures/gates/nor_gate.png[/img][/center][/font_size]
[hr]
Tutaj zasada działa jest podobna jak w NAND. Ta bramka jest połączeniem [b]N[/b]OT i [b]OR[/b].
Czyli wyjście jest pozytywne tylko i wyłącznie kiedy żadne wejście nie jest pozytywne.
Dla przypomnienia:

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=2228]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table] Odwrócenie wyniku: [table=1,center]
[cell border=white padding=1,0,1,5][b][char=AC](A[char=2228]B)[/b][/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[/table][/center]

[hr]
Stwórz tablicę prawdy dla bramki NOR."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 6

	play_ui_sound.emit()


func _on_lesson_button_7_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka XOR   [img=64]res://assets/resources/textures/gates/xor_gate.png[/img][/center][/font_size]
[hr]
XOR jest kombinacją wyrażenia algebraicznego. Jest wyrażana symbolem [b][char=22BB][/b]. Jej pełne wyrażenie można zapisać jako:
	A[char=22BB]B = (A [char=2227] [char=AC]B) [char=2228] ([char=AC]A [char=2227] B), albo
	A[char=22BB]B = (A [char=2228] B) [char=2227] [char=AC](A [char=2227] B).

Prościej tłumacząc: Wyjście jest pozytywne tylko i wyłącznie kiedy jedno z wejść jest pozytywne.

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=22BB]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[/table][/center]


[hr]
Stwórz tablicę prawdy dla bramki XOR.
Tym razem do wykonania zadania będzie dostępne więcej miejsca."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 7

	play_ui_sound.emit()


func _on_lesson_button_8_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka XNOR   [img=64]res://assets/resources/textures/gates/xnor_gate.png[/img][/center][/font_size]
[hr]
Podobna sytuacja jak z bramkami NAND i NOR, czyli połączenie [b]N[/b]OT i [b]XOR[/b].
To znaczy, żeby wyjście było pozytywne, obydwa wejścia muszą mieć ten sam sygnał. Nie ważne w jakim stanie.

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]A[char=22BB]B[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table]		[table=1,center]
[cell border=white padding=1,0,1,5][b][char=AC](A[char=22BB]B)[/b][/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table][/center]

[hr]
Stwórz tablicę prawdy dla bramki XNOR."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 8

	play_ui_sound.emit()


func _on_lesson_button_9_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Półpełny sumator[/center][/font_size]
[hr]
Pierwszy układ!
Tutaj stworzysz sumator półpełny. Taki układ wykonuje operację dodawania dwóch bitów.
Tablica prawdy wygląda następująco:

[center][table=4,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]Suma[/b][/cell]
[cell border=white padding=1,0,1,5][b]Przeniesienie[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[/table][/center]

[hr]
Wykonaj sumator z podanymi instrukcjami."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 9

	play_ui_sound.emit()


func _on_proceed_button_pressed() -> void:
	change_scene_level_selected.emit(lesson_selected)


func _on_introduction_button_pressed() -> void:
	introduction_visibility(false)
	SaveProgress.dialogue_1 = true
	SaveProgress.update_save_file()

	play_ui_sound.emit()


func _on_reintroduce_button_pressed() -> void:
	introduction_visibility(true)
	SaveProgress.dialogue_1 = true
	SaveProgress.update_save_file()

	play_ui_sound.emit()


func _on_dialogue_button_2_pressed() -> void:
	start_conversation(&"dialogue_2")
	SaveProgress.dialogue_2 = true
	SaveProgress.update_save_file()

	level_button_104.disabled = false


func _on_lesson_button_12_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Pełny sumator[/center][/font_size]
[hr]
Tak samo jak z poprzednim sumatorem. Tylko tym razem należy uwzględnić jeszcze dodatkowe wyjście przeniesienia.
Czyli teraz

[hr]
Zbuduj pełny sumator"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 12

	play_ui_sound.emit()


func _on_lesson_button_13_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Multiplekser 4x1[/center][/font_size]
[hr]
Teraz pora na większy multiplekser. Ta sama zasada działania. Więcej wejść i przełączników.

[hr]
Zbuduj multiplekser z 4 wejściami i 2 przełącznikami."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 13

	play_ui_sound.emit()


func _on_lesson_button_14_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Multiplekser 2x1[/center][/font_size]
[hr]
Pora na prosty multiplekser (MUX)!
Jest to układ który ma kilka wejść i w zależności od sygnału przełącznika, przesyła sygnał konkretnego wyjścia dalej.
Tak wygląda tablica prawdy multipleksera, który posiada 2 wejścia i 1 przełącznik:

[center][table=4,center]
[cell border=white padding=1,0,1,5][b]Przełącznik[/b][/cell]
[cell border=white padding=1,0,1,5][b]Wejście 1[/b][/cell]
[cell border=white padding=1,0,1,5][b]Wejście 2[/b][/cell]
[cell border=white padding=1,0,1,5][b]Wyjście[/b][/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table][/center]

Może się wydawać trochę duże. Ale działanie jest naprawdę proste. Możesz zauważyć, że jeśli przełącznik ma sygnał 0, to wyjście jest zależne tylko i wyłącznie od wejścia 1. Tak samo, kiedy przełącznik ma sygnał 1, to wyjście jest zależne tylko i wyłącznie od wejścia 0.

[hr]
Zbuduj multiplekser 2x1"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 14

	play_ui_sound.emit()


func _on_learn_button_2_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Tablice prawdy[/center][/font_size]
[hr]
Tablice prawdy działają w bardzo prosty sposób.
Dla prostych układów, można podstawić wszystkie możliwości danej funkcji. Funkcje, które można zapisać zamiast dla skróconego pisma w wielu odwołaniach.
f(x, y, z) = x ∧ ¬y ∨ z
O tym co te symbole oznaczają, będzie w późniejszych krokach.

Przykładowy zapis tablicy prawdy z dwoma zmiennymi bez wyniku:   [table=2,center]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[/table]"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = false

	play_ui_sound.emit()


func _on_level_button_103_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Negacja[/center][/font_size]
[hr]
Negacja (nie) jest spójnikiem jednoargumentowym.
[font_size=40][center]¬x[/center][/font_size]
Oznacza to, że wyjście jest 1 (prawda) tylko jeśli wejście jest 0 (fałsz).
W przeciwnym wypadku wyjście jest 0 (fałsz).

Bramka AND [img=64]res://assets/resources/textures/not_gate_button.png[/img] wykonuje tę operację.

Można przedstawić następująco:
¬0 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_9.png[/img]
¬1 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_10.png[/img]
Co za tym idzie, jeśli podwójnie zanegujesz wartość, to się nie zmieni.

Więc biorąc te rzeczy pod uwagę można stworzyć tablicę prawdy:

[center][table=2]
[cell border=white] [b]¬x[/b] [/cell]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[/table][/center]

Sprawdzisz bramkę w praktyce.




"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 103

	play_ui_sound.emit()


func _on_level_button_104_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Kilka bramek[/center][/font_size]
[hr]
Koniunkcja i koniunkcja, albo dysjunkcja. Tak brzmi lepiej.



W tym zadaniu, z trzech wejść spróbujesz zrobić kombinację koniunkcji i dysjunkcji, aby osiągnąć zamierzony wynik.
Funkcja będzie podpisana na wyjściu




"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 104

	play_ui_sound.emit()


func _on_learn_button_3_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Negowanie wszystkiego[/center][/font_size]
[hr]
Każda bramka logiczna może być połączona z negacją w jedną bramkę. W tym programie są na to specjalnie przygotowane osobne bramki.
Elementem odróżniającym te bramki jest kółko po prawej stronie bramki.

Weźmy na przykład AND

Działanie NAND to bramka AND połączona z NOT.

Zatem biorąc oryginalną tablicę     [table=3,center]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]x ∧ y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[/table]     wystarczy odwrócić wynik     [table=3,center]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]x ∧ y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[/table]


[center][img=300]res://assets/resources/textures/dialogue_images/dialogue_2_1.png[/img]     [img=300]res://assets/resources/textures/dialogue_images/dialogue_2_5.png[/img]

[img=300]res://assets/resources/textures/dialogue_images/dialogue_2_2.png[/img]     [img=300]res://assets/resources/textures/dialogue_images/dialogue_2_6.png[/img]

[img=300]res://assets/resources/textures/dialogue_images/dialogue_2_3.png[/img]     [img=300]res://assets/resources/textures/dialogue_images/dialogue_2_7.png[/img]

[img=300]res://assets/resources/textures/dialogue_images/dialogue_2_4.png[/img]     [img=300]res://assets/resources/textures/dialogue_images/dialogue_2_8.png[/img][/center]


To samo się dzieje w przypadku OR na NOR, oraz jeszcze jednej bramki, którą wkrótce poznasz.

"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = false

	play_ui_sound.emit()


func _on_level_button_105_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Różne wejścia[/center][/font_size]
[hr]
Sprawdźmy teraz jak poradzisz sobie z NORem.

Pamiętaj, że NOR to jest połączenie OR i NOT. Czyli odwrotność zwykłego OR.

Musisz wykonać x ∧ ¬y nie mając do AND. Masz do dyspozycji NOT i NOR. Powodzenia!



"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 105

	play_ui_sound.emit()


func _on_learn_button_4_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka XOR[/center][/font_size]
[hr]
Albo inaczej exclusive or
[font_size=40][center]x ⊻ y[/center][/font_size]
Oznacza to, że wyjście jest 1 (prawda), jeśli tylko jedno wejście jest 1 (prawda).
W przeciwnym wypadku wyjście jest 0 (fałsz).

Bramka XOR [img=48]res://assets/resources/textures/gates/xor_gate.png[/img] wykonuje tę operację.

Można przedstawić następująco:
0 ∨ 0 = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_11.png[/img]
0 ∨ 1 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_12.png[/img]
1 ∨ 0 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_13.png[/img]
1 ∨ 1 = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_14.png[/img]

Więc biorąc te rzeczy pod uwagę można stworzyć tablicę prawdy:

[center][table=3]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]x ⊻ y[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[/table][/center]

Sprawdzisz bramkę w praktyce.




"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = false

	play_ui_sound.emit()


func _on_level_button_106_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Zrobienie XNOR[/center][/font_size]
[hr]
W teorii wiesz jak działa XOR. To teraz go odwróćmy i spróbujesz zrobić układ, który go udaje.

Odwróceniem XOR jest XNOR czyli połączenie XOR i NOT.
XNOR na wyjściu ma 1 tylko, gdy obydwa wejścia mają tą samą wartość (nie ważne jaką).

Prezentuje się to w taki sposób:
¬(0 ⊻ 0) = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_11.png[/img]
¬(0 ⊻ 1) = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_12.png[/img]
¬(1 ⊻ 0) = 0     [img=250]res://assets/resources/textures/dialogue_images/learn_13.png[/img]
¬(1 ⊻ 1) = 1     [img=250]res://assets/resources/textures/dialogue_images/learn_14.png[/img]

Można to zaprezentować w taki sposób na tablicy:

[center][table=3]
[cell border=white] [b]x[/b] [/cell]
[cell border=white] [b]y[/b] [/cell]
[cell border=white] [b]¬(x ⊻ y)[/b] [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 0 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[cell border=white] 1 [/cell]
[/table][/center]



Odwzorujesz to działanie za pomocą innych bramek.


"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 106

	play_ui_sound.emit()


func _on_dialogue_button_3_pressed() -> void:
	start_conversation(&"dialogue_3")
	SaveProgress.dialogue_3 = true
	SaveProgress.update_save_file()
