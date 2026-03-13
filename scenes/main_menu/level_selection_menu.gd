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
		["Kwiatkowski", "Cześć! Marcin jestem."],
		["Marcin", "Gadkę zostawimy na później, teraz spieszę się na spotkanie. Zrobię Ci szybki kurs naszego programu."],
		["Marcin", "W nim projektujemy i symulujemy układy, zanim pójdą do produkcji."],
		["Marcin", "Na początek przygotowałem Ci zestaw zadań, abyś szybko zrozumiał jak działa nasz program."],
		["Marcin", "Jak zrozumiesz już sterowanie, to zawołaj mnie i wytłumaczę co dalej."],
		["Marcin", "W razie czego możesz powtórzyć każdą rozmowę, klikając na przyciski z żółtym tekstem."],
	],
	[
		["Marcin", "Dobra. Wygląda na to, że masz to już obcykane."],
		["Marcin", "Dam Ci teraz kilka prostych zleceń na start. Potem Cię przydzielę do czegoś większego."],
		["Marcin", "Masz tutaj jeszcze materiały tłumaczące działanie każdej bramki. Każdy pracownik takie dostaje."],
		["Marcin", "Dobra, to ty działaj. A ja lecę na kolejne spotkanie."],
		["Marcin", "Możesz powtórzyć każde zadanie w każdej chwili. Będzie wyświetlone poprzednie poprawne rozwiązanie, jeśli chcesz tylko rzucić na coś okiem."],
		["Marcin", 'Jeszcze Ci powiem, że w trakcie rysowania połączeń, jeśli naciśniesz przycisk [R] to wtedy "obracasz" połączenie do drugiego rogu w siatce.'],
		["Marcin", 'A kiedy naciśniesz przycisk [F] to wtedy twórz Ci punkt z które możesz kontynuować rysowanie.'],
	],
	[
		["Marcin", "Świetnie Ci poszło z tymi zadaniami. Spróbuj teraz je trochę rozwinąć."],
		["Marcin", "Większy multiplekser może zająć trochę czasu. Pamiętaj, że nie musisz się spieszyć i możesz wrócić do zadania w każdej chwili."],
	],
	[
		["Marcin", "Ładnie wykonana robota! Świetnie sobie poradziłeś ze wszystkim."],
		["Marcin", "Na dzisiaj skończyły mi się rzeczy, które mogę Ci dać do zrobienia."],
		["Marcin", "Choć do kawiarni. Pokażę Ci jakie przysmaki tam mają."],
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

@onready var lesson_button_2: Button = %LessonButton2
@onready var lesson_button_3: Button = %LessonButton3
@onready var lesson_button_4: Button = %LessonButton4
@onready var lesson_button_5: Button = %LessonButton5
@onready var lesson_button_6: Button = %LessonButton6
@onready var lesson_button_7: Button = %LessonButton7
@onready var lesson_button_8: Button = %LessonButton8
@onready var lesson_button_9: Button = %LessonButton9
@onready var lesson_button_10: Button = %LessonButton10
@onready var lesson_button_11: Button = %LessonButton11
@onready var lesson_button_12: Button = %LessonButton12
@onready var lesson_button_13: Button = %LessonButton13
@onready var lesson_button_14: Button = %LessonButton14
@onready var dialogue_button_2: Button = %DialogueButton2
@onready var dialogue_button_3: Button = %DialogueButton3
@onready var dialogue_button_4: Button = %DialogueButton4

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


func _on_lesson_button_1_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Witaj w poziomie wprowadzającym![/center][/font_size]
[hr]
Na sam początek przypomnimy w skrócie algebrę Boole'a.
[ul]Dana zmienna (np. [i]a[/i]) może mieć tylko jedną z dwóch wartości: 0 lub 1.[/ul]
[ul]1 jest prawdą, 0 jest fałszem.[/ul]
Każda operacja będzie dokładniej wyjaśniona w swoich lekcjach. Jest to niezwykle ważny temat, który jest nieodzłączną częścią układów.

W tej lekcji zostanie wytłumaczone odczytywanie tablic prawdy, oraz jak wygląda tworzenie połączeń pomiędzy złączeniami.

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

Przykłady poprawnych tablic będą zaprezentowane w nastepnych lekcjach (oraz prostsza wersja w tej lekcji). Teraz pora na odrobinę praktyki.
[hr]
W tym zadaniu musisz połączyć ze sobą wejście (początek) i wyjście (koniec) układu. Na planszy będą się znajdować obydwa zakończenia. Wystarczy je połączyć!"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 1

	play_ui_sound.emit()


func _on_lesson_button_10_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Układ nie składa się tylko z jednego połączenia[/center][/font_size]
[hr]
W układzie może znajdować się wiele połączeń, które robią inne rzeczy. Mogą się krzyżować lub rozdzielać.

Rozwidlenie oznaczone kropką: [img=64]res://assets/resources/textures/crossing.png[/img]. Skrzyżowanie bez kropki: [img]res://assets/resources/textures/crossing_no.png[/img]

[hr]
W tym zadaniu połączysz ze sobą konkretne złączenia, według tablicy prawdy:

[center][table=4,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b] Y [/b][/cell]
[cell border=white padding=1,0,1,5][b] Z [/b][/cell]
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
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]0[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[cell border=white padding=1,0,1,5]1[/cell]
[/table][/center]"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 10

	play_ui_sound.emit()


func _on_lesson_button_11_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Rozwidlenia[/center][/font_size]
[hr]
Tutaj będzie poruszona ta sama kwestia. Tylko teraz jedno wyjście będzie rozprowadzone do kilku wyjść.

[hr]
Połącz jedno wejście do kilku konkretnych wyjść."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 11

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
	lesson_button_2.disabled = not SaveProgress.dialogue_2
	lesson_button_3.disabled = not SaveProgress.dialogue_2
	lesson_button_4.disabled = not SaveProgress.dialogue_2
	lesson_button_5.disabled = not SaveProgress.dialogue_2
	lesson_button_6.disabled = not SaveProgress.dialogue_2
	lesson_button_7.disabled = not SaveProgress.dialogue_2
	lesson_button_8.disabled = not SaveProgress.dialogue_2
	lesson_button_9.disabled = not SaveProgress.dialogue_2


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


func _on_dialogue_button_3_pressed() -> void:
	start_conversation(&"dialogue_3")
	SaveProgress.dialogue_3 = true
	SaveProgress.update_save_file()
	lesson_button_12.disabled = not SaveProgress.dialogue_3


func _on_dialogue_button_4_pressed() -> void:
	start_conversation(&"dialogue_4")
	SaveProgress.dialogue_4 = true
	SaveProgress.update_save_file()
