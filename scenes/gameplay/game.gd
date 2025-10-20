extends Node
class_name TriageGame

signal request_medicine()
signal recieved_medicine()
signal use_medicine()
signal display(text : String)
signal has_dialogue(text : String)

signal request_item(item : MedicineData)
signal recieved_item()

@onready var rng := RandomNumberGenerator.new()

@onready var landing : Landing = preload("res://scenes/landing/landing.tscn").instantiate()
@onready var cabinet : MedicineCabinetUI = preload("res://scenes/medicine_cabinet/medicine_cabinet_ui.tscn").instantiate()
var patients : Array[Patient] = []
var backlog : Array[PatientData] = []

var medicine : MedicineData

func initialize_landing() -> void:
	landing.zone_click.connect(go_to)
	add_child(landing)

func initiate_cabinet() -> void:
	cabinet.button_pressed.connect(attempt_add_item)
	add_child(cabinet)

func initialize_patient() -> void:
	for i in range(3):
		var patient : Patient = load("res://scenes/patient/patient.tscn").instantiate()
		patients.append(patient)
		patient.id = i
		patient.visible = false
		patient.display.connect(display.emit)
		patient.limb_click.connect(attempt_heal)
		patient.cured.connect(patient_cured)
		add_child(patient)

func initialize_random(state : Array) -> void:
	backlog = []
	for patient in range(state[0]):
		var num_injuries : int = rng.randi_range(state[1], state[2])
		backlog.append(PatientRandomizer.make(str(patient), num_injuries))
		print(str("Made bed ", patient))

func populate_bed(bed : int = -1):
	print(str("Populating bed ", bed))
	if backlog.is_empty(): return
	if patients.all(func(p): return p != null and p.patient_data != null): return
	
	if bed < 0:
		bed = rng.randi_range(0, 2)
		while patients[bed].patient_data != null:
			bed = rng.randi_range(0, 2)
	patients[bed].patient_data = backlog[0]
	patients[bed].populate()
	backlog.remove_at(0)

func go_to_bed(bed : int) -> void:
	for patient in patients:
		patient.visible = false
	
	display.emit("")
	landing.visible = false
	cabinet.visible = false
	patients[bed].visible = true
	
	if patients[bed].is_dialogue:
		has_dialogue.emit(patients[bed].dialogue)
	
func go_to(location_name : String) -> void:
	match location_name.to_upper():
		"BED1":
			go_to_bed(0)
		"BED2":
			go_to_bed(1)
		"BED3":
			go_to_bed(2)
		"CABINET":
			go_to_cabinet()

func go_to_landing() -> void:
	for patient in patients:
		patient.visible = false
	
	cabinet.visible = false
	landing.visible = true

func go_to_cabinet() -> void:
	for patient in patients:
		patient.visible = false
	
	cabinet.visible = true
	landing.visible = false

func attempt_heal(limb: int, id: int) -> void:
	#print(Patient.Limbs.find_key(limb))
	medicine = null
	request_medicine.emit()
	await recieved_medicine
	if not medicine:
		#print("none")
		return
	
	#print(medicine)
	
	#print(Patient.Limbs.find_key(limb))
	var result : Patient.Result = patients[id].cure(limb, medicine)
	print(Patient.Result.find_key(result))
	patients[id]._update_display(limb)
	if result == Patient.Result.CLEAR || Patient.Result.NOCLEAR:
		use_medicine.emit()
	medicine = null

func attempt_add_item(button : MedicineCabinetButton) -> void:
	if button.amount <= 0:
		return
	
	medicine = null
	request_item.emit(button.item)
	await recieved_item
	
	if not medicine:
		return
	
	button.amount -= 1
	medicine = null

func attempt_store_item(item : MedicineData) -> bool:
	
	var i = 0
	for med_item in cabinet.medicines:
		if med_item.reference == item.reference:
			break
		i += 1
	
	var button = cabinet.container.get_child(i)
	if button.amount + 1 > button.max_amount:
		return false
	
	button.amount += 1
	return true

func patient_cured(id : int) -> void:
	patients[id].patient_data = null
