extends Node

@onready var current_scene: Node = $MainMenu
var loaded_file_path: String
var scenes: Dictionary[String, PackedScene] = {
	"main menu": preload("res://scenes/main_menu/main_menu.tscn"),
	"level selection": preload("res://scenes/main_menu/level_selection_menu.tscn"),
	"playground": preload("res://scenes/levels/playground/playground.tscn"),
}


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
			print('Something went wrong with connecting "change_scene" signal')
	if loaded_file_path and new_scene == "playground":
		current_scene.propagade_file_path(loaded_file_path)


func _on_main_menu_change_scene(new_scene: String) -> void:
	_change_scene(new_scene)


func _on_main_menu_load_file(path: String) -> void:
	loaded_file_path = path
