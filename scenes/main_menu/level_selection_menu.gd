class_name LevelSelectionMenu extends Control

signal change_scene_main_menu()
signal change_scene_level_selected(id: int)
var lesson_selected: int = 0
@export var lessonExplanation: RichTextLabel
@export var proceedButton: Button


func introduction_visibility(visibility: bool) -> void:
	($Introduction as ColorRect).visible = visibility


func _on_back_pressed() -> void:
	change_scene_main_menu.emit()


func _on_lesson_button_1_pressed() -> void:
	var buffer_text: String = """
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
	lessonExplanation.text = buffer_text
	proceedButton.visible = true
	lesson_selected = 1


func _on_lesson_button_2_pressed() -> void:
	var buffer_text: String = """[font_size=25]Wytłumaczenie na czym polegają tablicy prawdy oraz kilka przykładów[/font_size][br]
[left]Tutaj to będzie zobrazowane przez obrazki (by nie formatować tego tekstem)[/left]"""
	lessonExplanation.text = buffer_text
	proceedButton.visible = true
	lesson_selected = 2


func _on_lesson_button_3_pressed() -> void:
	var buffer_text: String = """[font_size=25]Wstęp tutaj będzie krótki[/font_size][br]
[left]Zadania na układach będą bardziej sprawdzane na żywo[/left]"""
	lessonExplanation.text = buffer_text
	proceedButton.visible = true
	lesson_selected = 3


func _on_lesson_button_4_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_5_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_6_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_7_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_8_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_9_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_10_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_11_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_12_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_13_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_14_pressed() -> void:
	pass # Replace with function body.


func _on_lesson_button_15_pressed() -> void:
	pass # Replace with function body.


func _on_proceed_button_pressed() -> void:
	change_scene_level_selected.emit(lesson_selected)


func _on_introduction_button_pressed() -> void:
	introduction_visibility(false)
	SaveProgress.introduction = true
	SaveProgress.update_save_file()


func _on_reintroduce_button_pressed() -> void:
	introduction_visibility(true)
