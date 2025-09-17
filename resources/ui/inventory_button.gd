extends Button
class_name InventoryButton

signal inv_used(medicine : MedicineData, my_id : int)

var id : int = 0
var item : MedicineData = null
var is_enabled : bool = true

func _init():
	self.button_down.connect(used)

func used() -> void:
	if item:
		inv_used.emit(item, id)
