extends Control
class_name Manager

var main_menu : MainMenu

var game : TriageGame
var doctor : Doctor 
var doctor_canvas : CanvasLayer
var days : DayData = preload("res://presaved/day/days.tres")
var in_game := false

var current_day : int = 0
var end_of_day_menu : EndOfDay

var temp_cabinet_storage : Array[int] = []
var temp_inventory_storage : Array[MedicineData] = []

var end_game_stats : Array[int] = [0,0,0]

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
	
	
	if not main_menu.exit.is_connected(_on_menu_exit):
		main_menu.exit.connect(_on_menu_exit)
	
	if not main_menu.new_game.is_connected(_on_new_game):
		main_menu.new_game.connect(_on_new_game)
	
func _on_menu_exit() -> void:
	get_tree().quit()

func _on_new_game() -> void:
	current_day = 0
	game_setup(current_day)

func game_setup(day : int) -> void:
	cleanup()
	game = TriageGame.new()
	doctor = load("res://scenes/doctor/doctor.tscn").instantiate()
	doctor_canvas = CanvasLayer.new()

	add_child(game)
	add_child(doctor_canvas)
	doctor_canvas.add_child(doctor)
	if not doctor.return_to_landing.is_connected(landing):
		doctor.return_to_landing.connect(landing)
	if not doctor.item_selected.is_connected(item_selected):
		doctor.item_selected.connect(item_selected)
	if not doctor.send_away.is_connected(send_away):
		doctor.send_away.connect(send_away)
	doctor.dialogue.manager = self
	
	if not game.request_medicine.is_connected(medicine_request):
		game.request_medicine.connect(medicine_request)
	if not game.use_medicine.is_connected(remove_medicine):
		game.use_medicine.connect(remove_medicine)
	if not game.display.is_connected(doctor.patient_display.write):
		game.display.connect(doctor.patient_display.write)
	if not game.has_dialogue.is_connected(show_dialogue):
		game.has_dialogue.connect(show_dialogue)
	
		
	if not game.day_finished.is_connected(day_over):
		game.day_finished.connect(day_over)
	
	if !temp_cabinet_storage.is_empty():
		doctor.cabinet.set_medicine_amount(temp_cabinet_storage)
	if !temp_inventory_storage.is_empty():
		doctor.add_items_in_order(temp_inventory_storage)
	
	game.initialize_patient()
	game.initialize_landing()
	
	var day_data = days.data[day]
	
	for data in day_data:
		if data is PatientData:
			game.backlog.append(data)
		elif data is Array:
			var patient_array = []
			for i in range(data[0]):
				patient_array.append(PatientRandomizer.make(str(i + game.backlog.size()), randi_range(data[1], data[2])))
			game.backlog.append_array(patient_array)
	
	in_game = true
	fill_beds()

func end_of_day_setup() -> void:
	var day_stats : Array[int] = [game.cure_count, game.sent_count, game.dead_count]
	
	for i in range(3):
		end_game_stats[i] += day_stats[i]
	
	cleanup()
	end_of_day_menu = load("res://scenes/menus/end_of_day_menu.tscn").instantiate()
	add_child(end_of_day_menu)
	end_of_day_menu.set_text(day_stats)

	if current_day >= days.data.size():
		end_of_day_menu.continue_button.text = "END GAME"
		end_of_day_menu.continue_signal.connect(end_of_game)
	else:
		end_of_day_menu.continue_signal.connect(func() : game_setup(current_day))
	
	end_of_day_menu.exit_signal.connect(_on_menu_exit)

func end_of_game() -> void:
	cleanup()
	end_of_day_menu = load("res://scenes/menus/end_of_day_menu.tscn").instantiate()
	add_child(end_of_day_menu)
	end_of_day_menu.end_of_day_label.text = "Your Final Score:"
	end_of_day_menu.set_text(end_game_stats)
	end_of_day_menu.continue_button.visible = false
	end_of_day_menu.exit_signal.connect(_on_menu_exit)

func send_away() -> void:
	game.send_away()

func medicine_request() -> void:
	if doctor.selected_item_id < 0 || doctor.selected_item == null:
		game.medicine = null
		game.call_deferred("emit_signal", "recieved_medicine")
		return
	
	game.medicine = doctor.selected_item
	game.call_deferred("emit_signal", "recieved_medicine")

func remove_medicine() -> void:
	doctor.remove_selected_item()

func fill_beds() -> void:
	while true:
		if !in_game: break
		if game.backlog.is_empty(): break
		
		game.populate_bed()
		await get_tree().create_timer(5).timeout

func item_selected() -> void:
	if !game.at_cabinet:
		return
	
	if doctor.attempt_store_item_cabinet(doctor.selected_item):
		doctor.remove_selected_item(true)
	
	pass

func landing() -> void:
	doctor.return_button.visible = false
	game.go_to_landing()

func day_over() -> void:
	in_game = false
	current_day += 1
	temp_cabinet_storage = doctor.cabinet.get_medicine_amount()
	temp_inventory_storage = doctor.get_items_in_order()
	
	#save_game()
	
	end_of_day_setup()
	pass

func _physics_process(_delta):
	if in_game:
		doctor.return_button.visible = !game.landing.visible && !doctor.dialogue.visible
		doctor.kick_out_button.visible = doctor.return_button.visible && !game.on_dialogue
		doctor.patient_display.visible = !game.landing.visible && !game.at_cabinet
		doctor.cabinet.visible = game.at_cabinet

		game.landing.patient1.visible = game.patients[0].patient_data != null
		game.landing.patient2.visible = game.patients[1].patient_data != null
		game.landing.patient3.visible = game.patients[2].patient_data != null

func show_dialogue(text : String) -> void:
	if doctor.dialogue.dialogue.size() != 0:
		return
	
	doctor.dialogue.read_file(text)
	doctor.dialogue.visible = true
	doctor.dialogue.start()
	pass


func dialogue_lock_patient(args : Array = []) -> void:
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.is_locked = true

func dialogue_unlock_patient(args : Array = []) -> void:
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.is_locked = false

func dialogue_cure_patient(args : Array = []) -> void:
	var index := 0
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			patient.cured.emit(index)
			return
		index += 1
	
func dialogue_wait(args : Array = []) -> void:
	doctor.dialogue.visible = false
	await game.has_dialogue
	doctor.dialogue.visible = true

func dialogue_wait_find_injury(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
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
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.injuries[Patient.Limbs[args[1]]].erase(Data.recall(args[2]))
	selected_patient.update_sprites()

func dialogue_add_injury(args : Array = []) -> void:
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient.injuries[Patient.Limbs[args[1]]].append(Data.recall(args[2]))
	selected_patient.update_sprites()

func dialogue_update_display(args : Array = []) -> void:
	
	var selected_patient : Patient
	for patient in game.patients:
		if patient.patient_data && patient.patient_data.reference == args[0]:
			selected_patient = patient
			break
	
	selected_patient._update_display(Patient.Limbs[args[1]])

func dialogue_wait_treat_injury_fail(args : Array = []) -> void:
	doctor.dialogue.visible = false
	
	var selected_patient : Patient
	for patient in game.patients:
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

func dialogue_has_medicine(args: Array = []) -> void:
	for i in range(5):
		if doctor.inventory[i].item and doctor.inventory[i].item.reference == args[0]:
			doctor.dialogue.variables[args[1]] = Dialogue.Variable.new([args[1], "BOOL", "TRUE"])
			break
		else:
			doctor.dialogue.variables[args[1]] = Dialogue.Variable.new([args[1], "BOOL", "FALSE"])
	

func dialogue_remove_medicine(args: Array = []) -> void:
	for i in range(5):
		if doctor.inventory[i].item and doctor.inventory[i].item.reference == args[0]:
			doctor.select_item(doctor.inventory[i].item, i)
			doctor.remove_selected_item()
			break
