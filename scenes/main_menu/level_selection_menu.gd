extends Control

signal change_scene(new_scene: String)


func _on_back_pressed() -> void:
	change_scene.emit("main menu")
