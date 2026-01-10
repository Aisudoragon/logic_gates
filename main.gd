extends Node

@export var main_menu: Control
@export var level_selection: LevelSelectionMenu
@export var playground: Node2D
var loaded_file_path: String
@onready var current_node: CanvasItem = main_menu


func _ready() -> void:
	if not SaveProgress.load_save():
		print("File not found. Creating new progress file.")
		SaveProgress.create_save()
		return

	print("File found.")

	level_selection.introduction_visibility(not SaveProgress.introduction)
	# TODO zapisywać stan postępów gracza


func _change_scene(new_node: CanvasItem) -> void:
	current_node.visible = false
	new_node.visible = true

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
