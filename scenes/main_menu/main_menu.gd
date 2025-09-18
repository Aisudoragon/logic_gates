extends Control


func _on_lessons_button_pressed() -> void:
	visible = false

	var error: Error = get_tree().change_scene_to_file("res://scenes/main_menu/level_selection_menu.tscn")
	if error:
		printerr("Couldn't change to Level selection scene")


func _on_sandbox_button_pressed() -> void:
	($SandboxButtons as Control).visible = not ($SandboxButtons as Control).visible


func _on_new_board_button_pressed() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/levels/playground/playground.tscn")
	if error:
		printerr("Couldn't change to sandbox scene")


func _on_load_board_button_pressed() -> void:
	($LoadBoardDialog as FileDialog).visible = not ($LoadBoardDialog as FileDialog).visible


func _on_options_button_pressed() -> void:
	print("No options?")


func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
