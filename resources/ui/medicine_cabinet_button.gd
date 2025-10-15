extends Panel
class_name MedicineCabinetButton

signal pressed(button : MedicineCabinetButton)

@onready var button : Button = $VBoxContainer/Button
@onready var label : Label = $VBoxContainer/Label

var item : MedicineData
var amount : int
var max_amount : int

func _ready():
	update_icon()
	button.pressed.connect(func() : pressed.emit(self))

func update_icon() -> void:
	button.icon = null
	button.text = ""
	if item:
		if ResourceLoader.exists(item.asset_path):
			button.icon = load(item.asset_path)
		else:
			button.text = item.medicine_name

func _physics_process(_delta):
	label.text = str(amount, " / ", max_amount)
