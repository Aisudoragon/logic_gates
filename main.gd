extends Node

@export var background_image: Sprite2D
@export var main_menu: Control
@export var level_selection: LevelSelectionMenu
@export var playground: Playground
var loaded_file_path: String
@onready var current_node: CanvasItem = main_menu


func _ready() -> void:
	if not SaveProgress.load_save():
		print("File not found. Creating new progress file.")
		SaveProgress.create_save()


func _change_scene(new_node: CanvasItem) -> void:
	current_node.visible = false
	new_node.visible = true

	current_node = new_node

	background_image.visible = not playground.visible


func _on_change_scene_main_menu() -> void:
	_change_scene(main_menu)


func _on_change_scene_level_selection() -> void:
	level_selection.introduction_visibility(not SaveProgress.introduction)
	level_selection.lesson_button_2.disabled = not SaveProgress.level_1
	level_selection.lesson_button_3.disabled = not SaveProgress.level_2
	level_selection.lesson_button_4.disabled = not SaveProgress.level_3
	level_selection.lesson_button_5.disabled = not SaveProgress.level_4
	level_selection.lesson_button_6.disabled = not SaveProgress.level_5
	level_selection.lesson_button_7.disabled = not SaveProgress.level_6
	level_selection.lesson_button_8.disabled = not SaveProgress.level_7
	level_selection.lesson_button_9.disabled = not SaveProgress.level_8
	level_selection.lesson_button_10.disabled = not SaveProgress.level_9
	_change_scene(level_selection)


func _on_change_scene_playground(path: String) -> void:
	if path:
		playground.propagade_file_path(path)
	playground.wires.is_sandbox = true
	_change_scene(playground)


func _on_change_scene_options() -> void:
	pass


func _on_level_selection_menu_change_scene_level_selected(id: int) -> void:
	playground.load_level(id)
	playground.wires.is_sandbox = false
	_change_scene(playground)
