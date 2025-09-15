extends Resource
class_name MedicineData

@export var reference : String = ""
@export var medicine_name : String = ""
@export var treatments : Dictionary = {}
@export var size : int = 0
@export var consumable : bool = true
@export var asset_path : String = ""

func _init(reference : String = "", medicine_name : String = "", treatments : Dictionary = {}, size : int = 0, consumable : bool = true, asset_path = ""):
	self.reference = reference
	self.medicine_name = medicine_name
	self.treatments = treatments
	self.size = size
	self.consumable = consumable
	self.asset_path = asset_path
