class_name LevelSelectionMenu extends Control

signal change_scene_main_menu()
signal change_scene_level_selected(id: int)
signal play_ui_sound()
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

func introduction_visibility(visibility: bool) -> void:
	($Introduction as ColorRect).visible = visibility


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
[ul][char=2227] [char=2014] alternatywa (lub),[/ul]
[ul][char=2228] [char=2014] koniunkcja (i),[/ul]
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
[font_size=28][center]Bramka AND[/center][/font_size]
[hr]
Pora skorzystać z pierwszej bramki, AND (i).
[i]Jeśli nie wiesz jak działają bramki logiczne to ta lekcja wprowadzi Cię w trybie ekspresowym w ich działanie.[/i]

Posiada ona dwa wejścia i jedno wyjście. Działa tak samo jak koniunkcja w algebrze Boole'a, tzn. Że na wejściu, jeśli obydwa sygnały są pozytywne, to tylko wtedy na wyjściu również będzie pozytywny.
Można to przedstawić na tablicy prawdy w taki sposób:

[center][table=3,center]
[cell border=white padding=1,0,1,5][b] A [/b][/cell]
[cell border=white padding=1,0,1,5][b] B [/b][/cell]
[cell border=white padding=1,0,1,5][b]Wyjście[/b][/cell]
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
[font_size=28][center]Bramka NOT[/center][/font_size]
[hr]
Następna bramka, NOT (nie).

Ta bramka posiada jedno wejście i jedno wyjście. Ta bramka służy do odwrócenia sygnału. To znaczy, jeśli na wejściu jest sygnał 0, to na wyjściu jest sygnał 1 i na odwrót.

[hr]
W tej lekcji sprawdzisz działanie bramki NOT."""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 3

	play_ui_sound.emit()


func _on_lesson_button_4_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka NAND[/center][/font_size]
[hr]
Dodać opis zadania.

[hr]
Dodać cel zadania"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 4

	play_ui_sound.emit()


func _on_lesson_button_5_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka OR[/center][/font_size]
[hr]
Dodać opis zadania.
Dostajesz NAND do zrobienia, lmao.

[hr]
Dodać cel zadania"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 5

	play_ui_sound.emit()


func _on_lesson_button_6_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka NOR[/center][/font_size]
[hr]
Dodać opis zadania.
Dostajesz NAND do zrobienia, lmao.

[hr]
Dodać cel zadania"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 6

	play_ui_sound.emit()


func _on_lesson_button_7_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka XOR[/center][/font_size]
[hr]
Dodać opis zadania.
Dostajesz NAND do zrobienia, lmao.

[hr]
Dodać cel zadania"""
	lessonExplanation.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	proceedButton.visible = true
	lesson_selected = 7

	play_ui_sound.emit()


func _on_lesson_button_8_pressed() -> void:
	lessonExplanation.text = """
[font_size=28][center]Bramka XNOR[/center][/font_size]
[hr]
Dodać opis zadania.
Dostajesz NAND do zrobienia, lmao.

[hr]
Dodać cel zadania"""
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
	SaveProgress.introduction = true
	SaveProgress.update_save_file()

	play_ui_sound.emit()


func _on_reintroduce_button_pressed() -> void:
	introduction_visibility(true)

	play_ui_sound.emit()
