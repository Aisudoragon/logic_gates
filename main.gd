extends Node

@export var main_menu: Control
@export var level_selection: Control
@export var playground: Node2D
var loaded_file_path: String
@onready var current_node: CanvasItem = main_menu


func _enter_tree() -> void:
	if not FileAccess.file_exists(Filepaths.save_progress):
		SaveProgress.create_save()
	# TODO zapisywać stan postępów gracza


func _change_scene(new_node: CanvasItem) -> void:
	new_node.visible = true
	new_node.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_node.visible = false
	current_node.process_mode = Node.PROCESS_MODE_DISABLED

	current_node = new_node


func _on_change_scene_main_menu() -> void:
	_change_scene(main_menu)


func _on_change_scene_level_selection() -> void:
	_change_scene(level_selection)


func _on_change_scene_playground(path: String) -> void:
	if path:
		playground.propagade_file_path(path)
	_change_scene(playground)


func _on_change_scene_options() -> void:
	pass
