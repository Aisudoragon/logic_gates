extends Control

@onready var label: Label = $HBoxContainer/Label
@onready var label_2: Label = $HBoxContainer/Label2


func set_display(new_name: String) -> void:
	label.text = new_name


func set_element(_new_grid_position: Vector2i, new_state: bool) -> void:
	label_2.text = str(int(new_state))
