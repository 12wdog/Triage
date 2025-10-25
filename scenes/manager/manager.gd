extends Control
class_name Manager

var main_menu : MainMenu

var game : TriageGame
var doctor : Doctor 
var doctor_canvas : CanvasLayer
var days : DayData = preload("res://presaved/day/days.tres")
var in_game := false

var current_day : int = 0

func _ready() -> void:
	menu_setup()
	
func cleanup() -> void:
	var children = get_children()
	for child in children:
		child.queue_free()

func menu_setup() -> void:
	cleanup()
	main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	add_child(main_menu)
	
	main_menu.exit.connect(func() : get_tree().quit())
	main_menu.new_game.connect(func() : game_setup(0))


func game_setup(day : int) -> void:
	cleanup()
	game = TriageGame.new()
	doctor = load("res://scenes/doctor/doctor.tscn").instantiate()
	doctor_canvas = CanvasLayer.new()

	add_child(game)
	add_child(doctor_canvas)
	doctor_canvas.add_child(doctor)
	doctor.return_to_landing.connect(landing)
	doctor.item_selected.connect(item_selected)
	doctor.dialogue.manager = self
	
	game.request_medicine.connect(medicine_request)
	game.use_medicine.connect(remove_medicine)
	game.display.connect(doctor.patient_display.write)
	game.has_dialogue.connect(show_dialogue)
	
	game.request_item.connect(item_request)
	
	game.day_finished.connect(day_over)

	game.initialize_patient()
	game.initialize_landing()
	game.initiate_cabinet()
	
	#game.backlog.append(DialoguePatientData.new("ref1", {}, "patient", "res://dialogue/dialogue_text/test_dialogue.txt"))
	var tutorial_patient : DialoguePatientData = load("res://presaved/patients/tut.tres")
	game.backlog.append(tutorial_patient)
	#game.initialize_random([1,2,2])
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

func item_request(item : MedicineData) -> void:
	var can_add = doctor.add_item(item)
	if can_add:
		game.medicine = item
	
	game.call_deferred("emit_signal", "recieved_item")

func remove_medicine() -> void:
	print("Removing medicine...")
	doctor.remove_selected_item()

func fill_beds() -> void:
	print("Making beds")
	print(game.backlog.size())
	while true:
		if !in_game: break
		if game.backlog.is_empty(): break
		
		game.populate_bed()
		await get_tree().create_timer(30).timeout
		print("Timer done")
	print("Loop done")

func item_selected() -> void:
	if !game.cabinet.visible:
		return
	
	if game.attempt_store_item(doctor.selected_item):
		doctor.remove_selected_item(true)
	
	pass

func landing() -> void:
	doctor.return_button.visible = false
	game.go_to_landing()

func day_over() -> void:
	in_game = false
	cleanup()
	current_day += 1
	pass

func save_game() -> void:
	var cabinet = game.cabinet.get_medicine_amount()
	var doc_med = doctor.get_items_in_order()
	var doc_dialogue_vars = doctor.dialogue.variables
	
	SaveGame.save(cabinet, doc_med, doc_dialogue_vars)

func _physics_process(_delta):
	if in_game:
		doctor.return_button.visible = !game.landing.visible && !doctor.dialogue.visible
		doctor.kick_out_button.visible = doctor.return_button.visible
		doctor.patient_display.visible = !(game.landing.visible || game.cabinet.visible)

func show_dialogue(text : String) -> void:
	if doctor.dialogue.dialogue.size() != 0:
		return
	
	doctor.dialogue.read_file(text)
	doctor.dialogue.visible = true
	doctor.dialogue.start()
	pass


func dialogue_lock_patient(args : Array = []) -> void:
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.is_locked = true

func dialogue_unlock_patient(args : Array = []) -> void:
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.is_locked = false

func dialogue_cure_patient(args : Array = []) -> void:
	var index := 0
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.cured.emit(index)
			return
		index += 1
	

func dialogue_wait_find_injury(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	while true:
		var selected_limb = await selected_patient.shown_limb
		if selected_limb == args[1]: break
	
	doctor.dialogue.visible = true

func dialogue_wait_open_clipboard(_args : Array = []) -> void :
	doctor.dialogue.visible = false
	
	await doctor.clipboard_button.pressed
	
	doctor.dialogue.visible = true

func dialogue_force_medicine(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.force_medicine = true
	
	while true:
		var attempted_medicine = await selected_patient.medicine_input
		if (attempted_medicine[0] == args[1] && attempted_medicine[1].reference == args[2]):
			selected_patient.medicine_continue.emit(true)
			break
		else:
			selected_patient.medicine_continue.emit(false)
	
	selected_patient.force_medicine = false
	
	doctor.dialogue.visible = true

func dialogue_treat_injury(args : Array = []) -> void:
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	print(selected_patient.injuries)
	selected_patient.injuries[Patient.Limbs[args[1]]].erase(Data.recall(args[2]))

func dialogue_add_injury(args : Array = []) -> void:
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.injuries[Patient.Limbs[args[1]]].append(Data.recall(args[2]))

func dialogue_update_display(args : Array = []) -> void:
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient._update_display(Patient.Limbs[args[1]])

func dialogue_wait_treat_injury_fail(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.able_to_cure = -1 
	var temp_is_locked = selected_patient.is_locked
	selected_patient.is_locked = false
	await selected_patient.cure_attempted
	
	selected_patient.able_to_cure = 0
	selected_patient.is_locked = temp_is_locked
	
	doctor.dialogue.visible = true
	
func dialogue_wait_treat_injury_succeed(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data: print(patient.patient_data.reference)
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.able_to_cure = 1 
	var temp_is_locked = selected_patient.is_locked
	selected_patient.is_locked = false
	await selected_patient.cure_attempted
	
	selected_patient.able_to_cure = 0
	selected_patient.is_locked = temp_is_locked
	
	doctor.dialogue.visible = true
