class_name LevelSelectionMenu extends Control

signal change_scene_main_menu()
signal change_scene_level_selected(id: int)
signal play_ui_sound()

# Dialogue [Speaker, sentence], [Speaker, sentence]
var sentences: Array[Array] = [
	# Postacie:
		# Ja
		# Narrator
		# Kowalski - Szef
		# Kwiatkowski (Marcin)
	[
		["Kowalski - Szef", "Bardzo się cieszymy, że dołączył Pan do naszego zespołu!"],
		["Kowalski - Szef", "Zajmę się się teraz formalnościami. Dla Pana został przydzielony nasz inżynier Kwiatkowski."],
		["Kowalski - Szef", "W tym czasie proszę udać się na swoje stanowisko, a Pan Kwiatkowski niedługo przybędzie."],
		["Narrator", "[i]Idziesz do twojego nowego stanowiska. Po kilku minutach zjawia się przydzielony inżynier.[/i]"],
		["Kwiatkowski", "Cześć! Marcin jestem."],
		["Marcin", "Gadkę zostawimy na później, bo się teraz spieszę na spotkanie. Zrobię Ci szybki kurs naszego programu."],
		["Marcin", "W nim projektujemy i symulujemy układy, zanim pójdą do produkcji."],
		["Marcin", "Na początek przygotowałem Ci zestaw zadań, abyś szybko zrozumiał jak działa nasz program."],
		["Marcin", "Jak zrozumiesz już sterowanie, to zawołaj mnie i wytłumaczę co dalej."],
	],
]
# Dialogue_X, sentences
var dialogues: Dictionary[StringName, Array] = {
	&"dialogue_1": sentences[0]
}
var current_dialogue: Array

var lesson_selected: int = 0
@export var lessonExplanation: RichTextLabel
@export var proceedButton: Button

@onready var lesson_button_2: Button = %LessonButton2
@onready var lesson_button_3: Button = %LessonButton3
@onready var lesson_button_4: Button = %LessonButton4
@onready var lesson_button_5: Button = %LessonButton5
@onready var lesson_button_6: Button = %LessonButton6
@onready var lesson_button_7: Button = %LessonButton7
@onready var lesson_button_8: Button = %LessonButton8
@onready var lesson_button_9: Button = %LessonButton9
@onready var lesson_button_10: Button = %LessonButton10

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

	if this_sentence[0] == "Ja" or this_sentence[0] == "Narrator":
		speaker_image.texture = ImageTexture.new()
	else:
		speaker_image.texture = pick_image_for_dialogue(this_sentence[0])


func pick_image_for_dialogue(speaker: String) -> ImageTexture:
	var image := Image.load_from_file("res://assets/resources/textures/dialogue_avatars/%s.png" % speaker)
	return ImageTexture.create_from_image(image)


func _on_back_pressed() -> void:
	change_scene_main_menu.emit()
	lessonExplanation.text = "[center]Wybierz zadanie, aby lepiej się z nim zapoznać.[/center]"
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	proceedButton.visible = false


func _on_lesson_button_1_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Witaj w twojej pierwszej lekcji![/center][/font_size]
[hr]
Na sam początek przypomnimy w skrócie algebrę Boole'a.
[ul]Dana zmienna (np. [i]a[/i]) może mieć tylko jedną z dwóch wartości: 0 lub 1.[/ul]
[ul]1 jest prawdą, 0 jest fałszem.[/ul]
Występują w niej również działania takie jak:
[ul][char=2228] [char=2014] alternatywa (lub),[/ul]
[ul][char=2227] [char=2014] koniunkcja (i),[/ul]
[ul][char=AC] [char=2014] negacja (nie).[/ul]
Każda operacja będzie dokładniej wyjaśniona w swoich lekcjach. Jest to niezwykle ważny temat, który jest nieodzłączną częścią układów.

W tej lekcji zostanie wytłumaczone odczytywanie tablic prawdy, oraz jak wygląda układ scalony.

Tablica prawdy składa się z trzech elementów, które mogą (nie muszą) pojawić się wielokrotnie:

[center][table=6,center]
[cell border=white padding=1,0,1,5][b]zmienna[/b][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]zmienna[/color][/cell]
[cell border=white padding=1,0,1,5][b]wyrażenie[/b][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wyrażenie[/color][/cell]
[cell border=white padding=1,0,1,5][b]wartość[/b][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]...[/color][/cell]
[cell border=white padding=1,0,1,5][color=dim_gray]wartość[/color][/cell]
[/table][/center]

zmienna [char=2014] reprezentuje dany symbol. Np. a.
wyrażenie [char=2014] reprezentuje pewne działanie. Np. a[char=2227]b.
wartość [char=2014] reprezentuje 0 lub 1.

Przykłady poprawnych tablic będą zaprezentowane w nastepnych lekcjach (oraz prostsza wersja w tej lekcji). Teraz pora na odrobinę praktyki. Na początek coś prostego!
[hr]
W tym zadaniu musisz połączyć ze sobą wejście (początek) i wyjście (koniec) układu. Na planszy będą się znajdować obydwa zakończenia. Wystarczy je połączyć kablem!"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 1

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
Następne kilka zadań wprowadzą Cię po kolei w każdą, dostępną bramkę logiczną. W tej lekcji, zobaczysz jak się taką wstawia do układu, oraz jak ją połączyć."""
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
Tutaj połączysz bramki ze sobą kablem. Takie połączenia będą rosnąć z kolejnymi poziomami."""
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
[font_size=28][center]Bramka SR Latch[/center][/font_size]
[hr]
Dodać opis zadania.

[hr]
Dodać cel zadania"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 9

	play_ui_sound.emit()


func _on_lesson_button_10_pressed() -> void:
	pass # Replace with function body.

	play_ui_sound.emit()


func _on_proceed_button_pressed() -> void:
	change_scene_level_selected.emit(lesson_selected)


func _on_introduction_button_pressed() -> void:
	introduction_visibility(false)
	SaveProgress.dialogue_1 = true
	SaveProgress.update_save_file()
	($LevelSelection/PanelContainer2/HBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ReintroduceButton as Button).focus_mode = Control.FOCUS_NONE

	play_ui_sound.emit()


func _on_reintroduce_button_pressed() -> void:
	introduction_visibility(true)

	play_ui_sound.emit()
