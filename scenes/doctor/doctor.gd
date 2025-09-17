extends Control
class_name Doctor

const button_size : float = 100.0

@onready var inventory : Array[Button] = [
	$PanelContainer/MarginContainer/HBoxContainer/Inv1,
	$PanelContainer/MarginContainer/HBoxContainer/Inv2,
	$PanelContainer/MarginContainer/HBoxContainer/Inv3,
	$PanelContainer/MarginContainer/HBoxContainer/Inv4,
	$PanelContainer/MarginContainer/HBoxContainer/Inv5
]
var inventory_used : int = 0
var selected_item : MedicineData = null
var selected_item_id : int = -1

func _ready():
	var i := 0
	for button in inventory:
		button.custom_minimum_size.x = button_size
		button.custom_minimum_size.y = button_size
		button.id = i
		button.inv_used.connect(select_item)
		i += 1
	
	add_item(Data.recall("serum"))
	add_item(Data.recall("surgery"))
	add_item(Data.recall("amputation"))

func add_item(item: MedicineData) -> bool:
	if inventory_used + item.size > 5: return false
	
	inventory[inventory_used].item = item
	if FileAccess.file_exists(item.asset_path):
		inventory[inventory_used].icon = load(item.asset_path)
	else: 
		inventory[inventory_used].text = item.medicine_name
	
	for i in range(1, item.size):
		inventory[inventory_used + i].is_enabled = false
		inventory[inventory_used + i].visible = false
		inventory[inventory_used].custom_minimum_size.x += button_size
	
	inventory_used += item.size
	return true

func remove_item(index: int) -> bool:
	if index < 0 or index >= inventory_used:
		return false
	
	# Find the starting slot of the item at this index
	var start_index := index
	while start_index > 0 and not inventory[start_index].is_enabled:
		start_index -= 1
	
	var item : MedicineData = inventory[start_index].item
	if item == null:
		return false
	
	var item_size := item.size
	
	# Step 1: gather all items that come AFTER the removed item
	var remaining_items : Array[MedicineData] = []
	var shift_index := start_index + item_size
	while shift_index < inventory_used:
		if inventory[shift_index].is_enabled and inventory[shift_index].item != null:
			var next_item : MedicineData = inventory[shift_index].item
			remaining_items.append(next_item)
			shift_index += next_item.size
		else:
			shift_index += 1
	
	# Step 2: clear the whole inventory
	for i in range(5):
		inventory[i].item = null
		inventory[i].icon = null
		inventory[i].text = ""
		inventory[i].is_enabled = true
		inventory[i].visible = true
		inventory[i].custom_minimum_size.x = button_size
	
	# Step 3: rebuild everything up to the removed slot
	inventory_used = start_index
	for next_item in remaining_items:
		add_item(next_item)
	
	return true

func select_item(medicine : MedicineData, id : int) -> void:
	selected_item = medicine
	selected_item_id = id
	
	print(str(selected_item, " ", selected_item_id))
