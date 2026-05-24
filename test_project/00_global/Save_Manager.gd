extends Node

const SAVE_PATH = "user://savegame_slot{0}.cfg"

const LEVEL_MAP = {
	"uid://d2btqn8sfli11": 1,
	"uid://ctnakk24novkh": 2,
	"uid://bea3qs0f5uqff": 3,
	"uid://df8u05p7a7t57": 4,
}

var current_slot : int = 1

var save_data = {
	"last_unlocked_level": 1
}

func get_slot_path(slot: int) -> String:
	return SAVE_PATH.format([slot])

func save():
	var config = ConfigFile.new()
	for key in save_data:
		config.set_value("game", key, save_data[key])
	config.save(get_slot_path(current_slot))
	print("Saved to slot ", current_slot)

func load_slot(slot: int):
	current_slot = slot
	var config = ConfigFile.new()
	if config.load(get_slot_path(slot)) != OK:
		print("No save in slot ", slot)
		return
	for key in save_data:
		save_data[key] = config.get_value("game", key, save_data[key])
	print("Loaded slot ", slot, " | Level: ", save_data["last_unlocked_level"])

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_slot_path(slot))

func get_slot_info(slot: int) -> String:
	if not slot_exists(slot):
		return "Empty"
	var config = ConfigFile.new()
	config.load(get_slot_path(slot))
	var level = config.get_value("game", "last_unlocked_level", 1)
	return "Level " + str(level)

func get_level_number(scene_path: String) -> int:
	var uid_str = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene_path))
	return LEVEL_MAP.get(uid_str, 0)
func delete_slot(slot: int):
	var path = get_slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Deleted slot ", slot)
