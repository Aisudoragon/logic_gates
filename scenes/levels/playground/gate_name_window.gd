extends Control

@export var text_edit: LineEdit

var current_gate_edit: Wires.GateTile


func _unhandled_input(_event: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


func edit_gate_name(gate_to_edit: Wires.GateTile) -> void:
	current_gate_edit = gate_to_edit
	text_edit.grab_focus()


func _on_button_pressed() -> void:
	if text_edit.text.is_empty():
		var characters := "QWERTYUIOPASDFGHJKLZXCVBNM"
		text_edit.text = characters.substr(randi_range(0, characters.length()), 1) + str(randi_range(0, 9))
	current_gate_edit.display_name = text_edit.text
	visible = false
	text_edit.text = ""
