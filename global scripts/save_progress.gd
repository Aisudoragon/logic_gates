class_name SaveProgress

static var introduction := false
static var level_1 := false
static var level_2 := false
static var level_3 := false
static var level_4 := false
static var level_5 := false
static var level_6 := false
static var level_7 := false
static var level_8 := false
static var level_9 := false
static var level_10 := false


static func update_save_file() -> void:
	var progress_dict := {
		"introduction": introduction,
		"level_1": level_1,
		"level_2": level_2,
		"level_3": level_3,
		"level_4": level_4,
		"level_5": level_5,
		"level_6": level_6,
		"level_7": level_7,
		"level_8": level_8,
		"level_9": level_9,
		"level_10": level_10,
	}
	var save_file := FileAccess.open(Filepaths.save_progress, FileAccess.WRITE)
	var success: bool = save_file.store_string(JSON.stringify(progress_dict, "\t"))
	if not success:
		printerr("Couldn't save progress to file")


static func ensure_directory_available() -> void:
	var dir: DirAccess = DirAccess.open("user://.levels")
	if not dir:
		var error: Error = DirAccess.make_dir_absolute("user://.levels")
		if error:
			printerr("Couldn't create directory")



static func create_save() -> void:
	update_save_file()


static func load_save() -> bool:
	var save_file := FileAccess.open(Filepaths.save_progress, FileAccess.READ)
	if not save_file:
		return false

	var progress_dict: Dictionary = JSON.parse_string(save_file.get_as_text())
	introduction = progress_dict["introduction"]
	level_1 = progress_dict["level_1"]
	level_2 = progress_dict["level_2"]
	level_3 = progress_dict["level_3"]
	level_4 = progress_dict["level_4"]
	level_5 = progress_dict["level_5"]
	level_6 = progress_dict["level_6"]
	level_7 = progress_dict["level_7"]
	level_8 = progress_dict["level_8"]
	level_9 = progress_dict["level_9"]
	level_10 = progress_dict["level_10"]

	return true
