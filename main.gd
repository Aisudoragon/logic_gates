extends Node

@onready var current_scene: Node = $MainMenu
var loaded_file_path: String
var scenes: Dictionary[String, PackedScene] = {
	"main menu": preload("res://scenes/main_menu/main_menu.tscn"),
	"level selection": preload("res://scenes/main_menu/level_selection_menu.tscn"),
	"playground": preload("res://scenes/levels/playground/playground.tscn"),
}


func _enter_tree() -> void:
	if not FileAccess.file_exists(Filepaths.save_progress):
		var new_save_template: String = FileAccess.open(Filepaths.save_template, FileAccess.READ).get_as_text()
		var progress_file := FileAccess.open(Filepaths.save_progress, FileAccess.WRITE)
		progress_file.store_string(new_save_template)

	# TODO zapisywać stan postępów gracza


func _instantiate_scene(path: String) -> Node:
	return scenes[path].instantiate()


func _change_scene(new_scene: String) -> void:
	var new_node: Node = _instantiate_scene(new_scene)
	add_child(new_node)
	current_scene.queue_free()
	current_scene = new_node
	if new_node.has_signal(&"change_scene"):
		var error: Error = new_node.connect(&"change_scene", _on_main_menu_change_scene)
		if error:
			printerr('[%d] Something went wrong with connecting "change_scene" signal' % error)
	if loaded_file_path and new_scene == "playground":
		current_scene.propagade_file_path(loaded_file_path)
		loaded_file_path = ""
	if current_scene.has_signal(&"load_file"):
		var error: Error = current_scene.load_file.connect(_on_main_menu_load_file)
		if error:
			printerr('[%d] Something went wrong with connecting to "load_file" signal' % error)


func _on_main_menu_change_scene(new_scene: String) -> void:
	if new_scene.begins_with("lesson_selection"):
		print(new_scene.erase(0, 16))
		loaded_file_path = "user://level1.circuit"
		_change_scene("playground")
	else:
		_change_scene(new_scene)


func _on_main_menu_load_file(path: String) -> void:
	loaded_file_path = path
