class_name Filepaths

static var save_progress := "user://progress.json"
static var save_template := "res://save_template.json"
static var custom_gates_directory := "user://customs"


static func file_path_to_level(level: int) -> String:
	return "res://scenes/levels/level_%d.json" % level


static func levels_dir_path(level: int) -> String:
	return "user://.levels/%s.json" % level
