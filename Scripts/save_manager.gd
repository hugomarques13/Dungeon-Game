extends Node

const SAVE_PATH = "user://savegame.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

func save(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Could not open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_save() -> Dictionary:
	if not has_save():
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("SaveManager: Could not open save file for reading")
		return {}
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("SaveManager: Failed to parse save file")
		return {}
	return parsed

func has_seen_dialogue(key: String) -> bool:
	var data = load_save()
	var seen: Array = data.get("seen_dialogues", [])
	return key in seen

func mark_dialogue_seen(key: String) -> void:
	var data = load_save()
	var seen: Array = data.get("seen_dialogues", [])
	if key not in seen:
		seen.append(key)
	data["seen_dialogues"] = seen
	save(data)
