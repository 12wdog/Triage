extends Node2D
class_name Manager

var game : TriageGame
var doctor : Doctor 
var doctor_canvas : CanvasLayer
var days : DayData = preload("res://presaved/day/days.tres")
var in_game := false

func _ready() -> void:
	game_setup(0)
		
	for patient in game.backlog:
		print(patient)
	
	landing()
	
func cleanup() -> void:
	var children = get_children()
	for child in children:
		child.queue_free()

func game_setup(day : int) -> void:
	game = TriageGame.new()
	doctor = load("res://scenes/doctor/doctor.tscn").instantiate()
	doctor_canvas = CanvasLayer.new()

	add_child(game)
	add_child(doctor_canvas)
	doctor_canvas.add_child(doctor)
	doctor.return_to_landing.connect(landing)
	
	game.request_medicine.connect(medicine_request)
	game.use_medicine.connect(remove_medicine)

	game.initialize_patient()
	game.initialize_landing()
	game.initiate_cabinet()
	game.initialize_random(days.data[day])
	
	in_game = true
	fill_beds()

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

func remove_medicine() -> void:
	print("Removing medicine...")
	doctor.remove_selected_item()

func fill_beds() -> void:
	#while true:
	if !in_game: return
	if game.backlog.is_empty(): return
	
	game.populate_bed()
	#await get_tree().create_timer(30).timeout

func landing() -> void:
	doctor.return_button.visible = false
	game.go_to_landing()

func _physics_process(_delta):
	doctor.return_button.visible = game.display.visible || game.cabinet.visible
