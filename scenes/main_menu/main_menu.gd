extends Control

signal change_scene_level_selection
signal change_scene_options
signal change_scene_playground(path: String)


func _on_lessons_button_pressed() -> void:
	change_scene_level_selection.emit()


func _on_sandbox_button_pressed() -> void:
	($SandboxButtons as Control).visible = not ($SandboxButtons as Control).visible


func _on_new_board_button_pressed() -> void:
	change_scene_playground.emit("")


func _on_load_board_button_pressed() -> void:
	($LoadBoardDialog as FileDialog).visible = not ($LoadBoardDialog as FileDialog).visible


func _on_options_button_pressed() -> void:
	print("No options?")


func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_load_board_dialog_file_selected(path: String) -> void:
	change_scene_playground.emit(path)
