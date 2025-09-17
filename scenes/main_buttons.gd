extends VBoxContainer


func _on_lessons_button_pressed() -> void:
	visible = false

	var error: Error = get_tree().change_scene_to_file("res://scenes/level_selection.tscn")
	if error:
		printerr("Couldn't change to Level selection scene")


func _on_sandbox_button_pressed() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/levels/playground/playground.tscn")
	if error:
		printerr("Couldn't change to playground scene")


func _on_options_button_pressed() -> void:
	print("No options?")


func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
