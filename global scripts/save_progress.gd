class_name SaveProgress

static var dialogue_1 := false
static var dialogue_2 := false
static var dialogue_3 := false
static var dialogue_4 := false
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
static var level_11 := false
static var level_12 := false
static var level_13 := false
static var level_14 := false


static func update_save_file() -> void:
	var progress_dict := {
		"dialogue_1": dialogue_1,
		"dialogue_2": dialogue_2,
		"dialogue_3": dialogue_3,
		"dialogue_4": dialogue_4,
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
		"level_11": level_11,
		"level_12": level_12,
		"level_13": level_13,
		"level_14": level_14,
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
	level_1 = progress_dict.get("level_1", false)
	level_2 = progress_dict.get("level_2", false)
	level_3 = progress_dict.get("level_3", false)
	level_4 = progress_dict.get("level_4", false)
	level_5 = progress_dict.get("level_5", false)
	level_6 = progress_dict.get("level_6", false)
	level_7 = progress_dict.get("level_7", false)
	level_8 = progress_dict.get("level_8", false)
	level_9 = progress_dict.get("level_9", false)
	level_10 = progress_dict.get("level_10", false)
	level_11 = progress_dict.get("level_11", false)
	level_12 = progress_dict.get("level_12", false)
	level_13 = progress_dict.get("level_13", false)
	level_14 = progress_dict.get("level_14", false)

	return true


static func open_customs_directory() -> DirAccess:
	var dir := DirAccess.open(Filepaths.custom_gates_directory)
	if not dir:
		var error: Error = DirAccess.make_dir_absolute(Filepaths.custom_gates_directory)
		if error:
			printerr("Failed to create customs folder.")
		dir = DirAccess.open(Filepaths.custom_gates_directory)
	return dir
