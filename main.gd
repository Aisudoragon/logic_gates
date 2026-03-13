extends Node

@export var background: TextureRect
@export var main_menu: Control
@export var level_selection: LevelSelectionMenu
@export var playground: Playground
@export var audio_player: AudioStreamPlayer
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

	background.visible = not playground.visible

	play_ui_sound()


func _on_change_scene_main_menu() -> void:
	_change_scene(main_menu)


func _on_change_scene_level_selection() -> void:
	level_selection.introduction_visibility(not SaveProgress.dialogue_1)
	level_selection.level_button_101.disabled = not (SaveProgress.dialogue_1)
	level_selection.level_button_102.disabled = not (SaveProgress.level_101)
	level_selection.level_button_103.disabled = not (SaveProgress.level_102)
	level_selection.dialogue_button_2.disabled = not (SaveProgress.level_103)
	level_selection.level_button_104.disabled = not (SaveProgress.dialogue_2)
	level_selection.learn_button_3.disabled = not (SaveProgress.level_104)
	level_selection.level_button_105.disabled = not (SaveProgress.level_104)
	level_selection.learn_button_4.disabled = not (SaveProgress.level_105)
	level_selection.level_button_106.disabled = not (SaveProgress.level_105)
	level_selection.dialogue_button_3.disabled = not (SaveProgress.level_106)

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


func play_ui_sound() -> void:
	audio_player.pitch_scale = randf_range(0.7, 1.0)
	audio_player.play()


func _on_play_ui_sound() -> void:
	play_ui_sound()
