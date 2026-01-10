class_name LevelSelectionMenu extends Control

signal change_scene_main_menu()
signal change_scene_level_selected(path: String)
var lesson_selected: int = 0
@export var lessonExplanation: RichTextLabel
@export var proceedButton: Button


func introduction_visibility(visibility: bool) -> void:
	($Introduction as ColorRect).visible = visibility


func _on_back_pressed() -> void:
	change_scene_main_menu.emit()


func _on_lesson_button_1_pressed() -> void:
	var buffer_text: String = """[font_size=25]Krótkie wprowadzenie do dziedziny (tekst z Wikipedii jako przykład)[/font_size][br]
[left]Bramka logiczna – element konstrukcyjny maszyn i mechanizmów (dziś zazwyczaj: układ scalony, choć te same funkcje można zrealizować również za pomocą dyskretnych elementów elektronicznych, a także w sferze innych rozwiązań technicznych, np. hydrauliki czy pneumatyki), realizujący fizycznie pewną prostą funkcję logiczną, której argumenty (zmienne logiczne) oraz sama funkcja mogą przybierać jedną z dwóch wartości, np. 0 lub 1 (zob. algebra Boole’a).[/left]"""
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
	change_scene_level_selected.emit("lesson_selection%d" % lesson_selected)


func _on_introduction_button_pressed() -> void:
	introduction_visibility(false)
	SaveProgress.introduction = true
	SaveProgress.update_save_file()


func _on_reintroduce_button_pressed() -> void:
	introduction_visibility(true)
