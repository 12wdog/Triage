@tool
extends EditorScript

class_name SaveGame

const save_path : String = "user://savegame.dat"

static func save(medicine_amount : Array[int] = [], doctor_inventory : Array[MedicineData] = [], variables : Dictionary = {}) -> void:
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	save_file.store_8(medicine_amount.size())
	
	for amount in medicine_amount:
		save_file.store_8(amount)
	
	
	save_file.store_8(doctor_inventory.size())
	
	for medicine in doctor_inventory:
		save_file.store_pascal_string(medicine.reference)
	
	
	save_file.store_8(variables.size())
	
	for key in variables.keys():
		save_file.store_pascal_string(key)
		var value : Dialogue.Variable = variables[key]
		
		save_file.store_8(value.dataType)
		
		match value.dataType:
			Dialogue.Variable.TYPES.BOOL:
				save_file.store_8(int(value.data))
			Dialogue.Variable.TYPES.INT:
				save_file.store_64(int(value.data))
			Dialogue.Variable.TYPES.STRING:
				save_file.store_pascal_string(value.data)
	

static func load() -> Array:
	
	if !FileAccess.file_exists(save_path):
		return []
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var output = []
	
	var med_count = save_file.get_8()
	output.append([])
	
	for i in range(med_count):
		output[0].append(save_file.get_8())
	
	
	var doc_count = save_file.get_8()
	output.append([])
	for i in range(doc_count):
		var med_name = save_file.get_pascal_string()
		var medicine : MedicineData = Data.recall(med_name)
		output[1].append(medicine)
	
	
	var vars_count = save_file.get_8()
	output.append({})
	
	for i in range(vars_count):
		var vars_name = save_file.get_pascal_string()
		var vars_type = save_file.get_8()
		
		var variable : Dialogue.Variable
		
		match vars_type:
			Dialogue.Variable.TYPES.BOOL:
				var vars_bool = "TRUE" if bool(save_file.get_8()) else "FALSE"
				variable = Dialogue.Variable.new([vars_name, "BOOL", vars_bool])
			Dialogue.Variable.TYPES.INT:
				var vars_int = save_file.get_64()
				variable = Dialogue.Variable.new([vars_name, "INT", str(vars_int)])
			Dialogue.Variable.TYPES.STRING:
				var vars_string = save_file.get_pascal_string()
				variable = Dialogue.Variable.new([vars_name, "STRING", vars_string])
		
		output[2][vars_name] = variable
	
	return output

func _run():
	var vars_dictionary : Dictionary = {}
	vars_dictionary["TEST"] = Dialogue.Variable.new(["TEST", "INT", "34"])
	vars_dictionary["TEST2"] = Dialogue.Variable.new(["TEST2", "STRING", "This is a test!"])
	SaveGame.save([4, 7, 1, 3, 9, 3], [MedicineData.new("painkiller", "Painkillers", {"light_bleed": [[0.4],[0.7,"painkiller",[0.3,"death"]]], "infection": [[0.3],[0.6,"painkiller",[0.3,"death"]]], "bullet": [[0.3],[0.6,"painkiller",[0.3,"death"]]], "shock": [[0.6],[0.9,"painkiller",[0.3,"death"]]]}, 1, true, "")], vars_dictionary)
	
	var loaded = SaveGame.load()
	print(loaded)
	print(loaded[1][0].medicine_name)
