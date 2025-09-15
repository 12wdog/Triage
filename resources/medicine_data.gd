extends Resource
class_name MedicineData

@export var medicine_name : String = ""
@export var treatments : Dictionary = {}
@export var asset_path : String = ""

func _init(medicine_name : String = "", treatments : Dictionary = {}, asset_path = ""):
	self.medicine_name = medicine_name
	self.treatments = treatments
	self.asset_path = asset_path
