extends Node2D
class_name Manager

var game := TriageGame.new()
@onready var doctor :Doctor = preload("res://scenes/doctor/doctor.tscn").instantiate()
@onready var doctor_canvas : CanvasLayer = $CanvasLayer
var days : DayData = preload("res://presaved/day/days.tres")

func _ready() -> void:
	add_child(game)
	doctor_canvas.add_child(doctor)
	
	game.request_medicine.connect(medicine_request)
	
	game.initialize_patient()
	#game.backlog.append(PatientData.new("tesst", {"RARM": ["light_bleed", "infection"]}))
	game.initialize_random([1, 4, 7])
	
	for patient in game.backlog:
		print(patient)
	
	game.populate_bed(0)
	game.go_to_bed(0)

func medicine_request() -> void:
	print("Medicine request")
	if doctor.selected_item_id < 0 || doctor.selected_item == null:
		print("No Medicine")
		game.medicine = null
		game.call_deferred("emit_signal", "recieved_medicine")
		return
	
	print("Medicine")
	game.medicine = doctor.selected_item
	game.call_deferred("emit_signal", "recieved_medicine")
