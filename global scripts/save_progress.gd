class_name SaveProgress

static var dialogue_1 := false
static var dialogue_2 := false
static var dialogue_3 := false
static var dialogue_4 := false
static var level_101 := false
static var level_102 := false
static var level_103 := false
static var level_104 := false
static var level_105 := false
static var level_106 := false


static func update_save_file() -> void:
	var progress_dict := {
		"dialogue_1": dialogue_1,
		"dialogue_2": dialogue_2,
		"dialogue_3": dialogue_3,
		"dialogue_4": dialogue_4,
		"level_101": level_101,
		"level_102": level_102,
		"level_103": level_103,
		"level_104": level_104,
		"level_105": level_105,
		"level_106": level_106,
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
	dialogue_1 = progress_dict.get("dialogue_1", false)
	dialogue_2 = progress_dict.get("dialogue_2", false)
	dialogue_3 = progress_dict.get("dialogue_3", false)
	dialogue_4 = progress_dict.get("dialogue_4", false)
	level_101 = progress_dict.get("level_101", false)
	level_102 = progress_dict.get("level_102", false)
	level_103 = progress_dict.get("level_103", false)
	level_104 = progress_dict.get("level_104", false)
	level_105 = progress_dict.get("level_105", false)
	level_106 = progress_dict.get("level_106", false)

	return true


static func open_customs_directory() -> DirAccess:
	var dir := DirAccess.open(Filepaths.custom_gates_directory)
	if not dir:
		var error: Error = DirAccess.make_dir_absolute(Filepaths.custom_gates_directory)
		if error:
			printerr("Failed to create customs folder.")
		dir = DirAccess.open(Filepaths.custom_gates_directory)
	return dir
