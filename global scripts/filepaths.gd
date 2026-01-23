class_name Filepaths

static var save_progress := "user://progress.json"
static var save_template := "res://save_template.json"


static func file_path_to_level(level: int) -> String:
	return "res://scenes/levels/level_%d.json" % level
