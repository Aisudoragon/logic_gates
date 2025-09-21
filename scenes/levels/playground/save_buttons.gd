extends HBoxContainer


var save_path: String


func _on_save_button_pressed() -> void:
	if not save_path.is_empty():
		var error := ($FileDialog as FileDialog).emit_signal(&"file_selected", save_path)
		assert(error == OK, "Couldn't emit signal")
		return
	($FileDialog as FileDialog).visible = not ($FileDialog as FileDialog).visible


func _on_file_dialog_file_selected(path: String) -> void:
	save_path = path


func _on_save_as_button_pressed() -> void:
	($FileDialog as FileDialog).visible = not ($FileDialog as FileDialog).visible
