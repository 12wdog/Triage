extends CanvasLayer
class_name MedicineCabinetUI
signal button_pressed(button : MedicineCabinetButton)
@onready var container = $MedicineCabinetUI/GridContainer

var medicines = [
	Data.recall("bandage"),
	Data.recall("serum"),
	Data.recall("antibiotic"),
	Data.recall("stitches"),
	Data.recall("painkiller"),
]


func _ready():
	for medicine in medicines:
		var button : MedicineCabinetButton = load("res://resources/ui/medicine_cabinet_button.tscn").instantiate()
		button.item = medicine
		button.max_amount = 20
		button.amount = 20
		button.name = medicine.reference
		button.pressed.connect(func(b) : button_pressed.emit(b))
		container.add_child(button)
