@tool
extends EditorScript

class_name SaveGame

const save_path : String = "user://savegame.dat"

static func save(medicine_amount : Array[int]) -> void:
	var save_file = FileAccess.open(save_path, FileAccess.WRITE_READ)
	
	save_file.store_8(medicine_amount.size())
	
	for amount in medicine_amount:
		save_file.store_8(amount)
	

static func load() -> Array:
	
	if !FileAccess.file_exists(save_path):
		return []
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var output = []
	
	var med_count = save_file.get_8()
	output.append([])
	
	for i in range(med_count):
		output[0].append(save_file.get_8())
	
	return output

func _run():
	SaveGame.save([4, 7, 1, 3, 9, 3])
	
	print(SaveGame.load())
