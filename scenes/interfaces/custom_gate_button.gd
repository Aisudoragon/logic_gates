class_name CustomGateButton extends Button

signal load_file(path: String)

var file_name: String


func _init(new_file_name: String) -> void:
	file_name = new_file_name

	text = file_name.get_basename()
	alignment = HORIZONTAL_ALIGNMENT_LEFT

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	load_file.emit(file_name)
