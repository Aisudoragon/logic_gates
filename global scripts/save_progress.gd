class_name SaveProgress

static var introduction := false
static var level_0 := false
static var level_1 := false
static var level_2 := false
static var level_3 := false


static func update_save_file() -> void:
	var progress_dict := {
		"introduction": introduction,
		"level_0": level_0,
		"level_1": level_1,
		"level_2": level_2,
		"level_3": level_3,
	}
	var save_file := FileAccess.open(Filepaths.save_progress, FileAccess.WRITE)
	var success: bool = save_file.store_string(JSON.stringify(progress_dict, "\t"))
	if not success:
		printerr("Couldn't save progress to file")


static func create_save() -> void:
	update_save_file()


static func load_save() -> bool:
	var save_file := FileAccess.open(Filepaths.save_progress, FileAccess.READ)
	if not save_file:
		return false

	var progress_dict: Dictionary = JSON.parse_string(save_file.get_as_text())
	introduction = progress_dict["introduction"]
	level_0 = progress_dict["level_0"]
	level_0 = progress_dict["level_1"]
	level_0 = progress_dict["level_2"]
	level_0 = progress_dict["level_3"]

	return true
