extends Node

@onready var current_scene: Node = $MainMenu
var scenes: Dictionary[String, PackedScene] = {
	"main_menu": preload("res://scenes/main_menu/main_menu.tscn"),
	"level_selection": preload("res://scenes/main_menu/level_selection_menu.tscn"),
	"playground": preload("res://scenes/levels/playground/playground.tscn"),
}


func _instantiate_scene(path: String) -> Node:
	return scenes[path].instantiate()


func _change_scene(new_scene: Node) -> void:
	add_child(new_scene)
	current_scene.queue_free()
	current_scene = new_scene


func _on_main_menu_change_scene(new_scene: String) -> void:
	_change_scene(_instantiate_scene(new_scene))
