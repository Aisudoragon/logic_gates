extends Control

signal signal_set(grid_position: Vector2i, state: bool)

var grid_position: Vector2i
var state: bool
@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button


func set_display(new_name: String) -> void:
	label.text = new_name
	button.text = str(int(state))


func set_element(new_grid_position: Vector2i, new_state: bool) -> void:
	grid_position = new_grid_position
	state = new_state


func _on_button_pressed() -> void:
	state = not state
	signal_set.emit(grid_position, state)
	button.text = str(int(state))
