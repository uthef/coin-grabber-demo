# сохранение и чтение дампов
class_name DataSaveManager extends Node

const FILE_PATH = "user://level.dat"

static func write(data: StoredLevelData):
	var file := FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(data.get_dict())
	file.close()


static func read() -> StoredLevelData:
	var file := FileAccess.open(FILE_PATH, FileAccess.READ)

	if FileAccess.get_open_error() != Error.OK:
		return StoredLevelData.new()
	
	var data := StoredLevelData.new(file.get_var() as Dictionary)
	file.close()

	return data


static func clear() -> void:
	write(StoredLevelData.new({}))
