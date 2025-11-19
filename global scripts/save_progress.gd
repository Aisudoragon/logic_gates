class_name SaveProgress

static var introduction := false:
	set(value):
		introduction = value
		_update_save_file()
static var level_0 := false:
	set(value):
		level_0 = value
		_update_save_file()
static var level_1 := false:
	set(value):
		level_1 = value
		_update_save_file()
static var level_2 := false:
	set(value):
		level_2 = value
		_update_save_file()
static var level_3 := false:
	set(value):
		level_3 = value
		_update_save_file()


static func _update_save_file() -> void:
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
	_update_save_file()
