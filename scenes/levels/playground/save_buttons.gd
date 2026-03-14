extends HBoxContainer

signal play_ui_sound()

var save_path: String


func _ready() -> void:
	SaveProgress.open_customs_directory()
	$SaveDialog.root_subfolder = "customs"


func _on_save_button_pressed() -> void:
	play_ui_sound.emit()

	if not save_path.is_empty():
		var error := ($SaveDialog as FileDialog).emit_signal(&"file_selected", save_path)
		assert(error == OK, "Couldn't emit signal")
		return
	($SaveDialog as FileDialog).visible = not ($SaveDialog as FileDialog).visible


func _on_file_dialog_file_selected(path: String) -> void:
	save_path = path


func _on_save_as_button_pressed() -> void:
	play_ui_sound.emit()
	($SaveDialog as FileDialog).visible = not ($SaveDialog as FileDialog).visible
