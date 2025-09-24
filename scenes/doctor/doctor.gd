extends Control
class_name Doctor

signal return_to_landing()

const button_size : float = 100.0

@onready var inventory : Array[Button] = [
	$PanelContainer/MarginContainer/HBoxContainer/Inv1,
	$PanelContainer/MarginContainer/HBoxContainer/Inv2,
	$PanelContainer/MarginContainer/HBoxContainer/Inv3,
	$PanelContainer/MarginContainer/HBoxContainer/Inv4,
	$PanelContainer/MarginContainer/HBoxContainer/Inv5
]
@onready var return_button : Button = $ReturnButton

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
	
	return_button.pressed.connect(func() : return_to_landing.emit())
	

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

func select_item(medicine : MedicineData, id : int) -> void:
	selected_item = medicine
	selected_item_id = id
	
	print(str(selected_item, " ", selected_item_id))

func _clear_inventory_ui() -> void:
	# Reset every inventory button back to a neutral state.
	for btn in inventory:
		# remove stored item reference + visuals
		btn.item = null
		btn.icon = null
		btn.text = ""
		# restore enabled/visible default
		btn.is_enabled = true
		btn.visible = true
		# reset any size changes done by add_item
		btn.custom_minimum_size.x = button_size

	inventory_used = 0
	selected_item = null
	selected_item_id = -1


func remove_selected_item() -> bool:
	# Returns true if an item was removed, false otherwise.
	if selected_item_id < 0 or selected_item == null:
		return false
		
	if not selected_item.consumable:
		return false
	
	# Find the "root" slot for the selected id: if someone somehow selected a
	# hidden slot, walk left to find the visible slot that actually owns the item.
	var root_idx := selected_item_id
	while root_idx >= 0 and inventory[root_idx].item == null:
		root_idx -= 1
	if root_idx < 0:
		return false

	# Build a compact ordered list of the items currently in the inventory
	var items_in_order : Array = []
	for i in range(inventory.size()):
		var btn = inventory[i]
		if btn.item != null:
			items_in_order.append(btn.item)

	# Compute which position in items_in_order corresponds to root_idx
	var pos := 0
	for i in range(root_idx):
		if inventory[i].item != null:
			pos += 1

	if pos < 0 or pos >= items_in_order.size():
		return false

	# Remove the selected item from the logical list
	items_in_order.remove_at(pos)

	# Clear the UI and re-add remaining items in order
	_clear_inventory_ui()
	for it in items_in_order:
		# add_item will re-hide/resize slots appropriately
		var ok := add_item(it)
		# If this ever fails something is inconsistent; bail out safely.
		if not ok:
			push_error("Rebuilding inventory failed while re-adding: %s" % str(it))
			return false

	return true
