extends Control

var current_gate_edit: Wires.GateTile


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


func edit_gate_name(gate_to_edit: Wires.GateTile) -> void:
	current_gate_edit = gate_to_edit
	$HBoxContainer/TextEdit.grab_focus()


func _on_button_pressed() -> void:
	current_gate_edit.display_name = $HBoxContainer/TextEdit.text
	visible = false
	$HBoxContainer/TextEdit.text = ""
