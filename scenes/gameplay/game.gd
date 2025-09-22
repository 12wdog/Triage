extends Node
class_name TriageGame

signal request_medicine()
signal recieved_medicine()

@onready var rng := RandomNumberGenerator.new()
@onready var display : PatientUI = preload("res://scenes/patient/patient_ui.tscn").instantiate()

var patients : Array[Patient] = []
var backlog : Array[PatientData] = []

var medicine : MedicineData

func initialize_patient() -> void:
	for i in range(3):
		var patient : Patient = load("res://scenes/patient/patient.tscn").instantiate()
		patients.append(patient)
		patient.id = i
		patient.visible = false
		patient.display.connect(write_to_display)
		patient.limb_click.connect(attempt_heal)
		add_child(patient)
	add_child(display)

func initialize_random(state : Array) -> void:
	backlog = []
	for patient in range(state[0]):
		var num_injuries : int = rng.randi_range(state[1], state[2])
		backlog.append(PatientRandomizer.make(str(patient), num_injuries))

func populate_bed(bed : int = -1):
	if backlog.is_empty(): return
	if bed < 0:
		bed = rng.randi_range(0, 2)
	patients[bed].patient_data = backlog[0]
	patients[bed].populate()
	backlog.remove_at(0)

func go_to_bed(bed : int) -> void:
	for patient in patients:
		patient.visible = false
	
	patients[bed].visible = true

func write_to_display(text : String) -> void:
	display.write(text)

func attempt_heal(limb: int, id: int) -> void:
	#print(Patient.Limbs.find_key(limb))
	request_medicine.emit()
	await recieved_medicine
	if not medicine:
		#print("none")
		return
	
	#print(medicine)
	
	#print(Patient.Limbs.find_key(limb))
	patients[id].cure(limb, medicine)
	patients[id]._update_display(limb)
	pass
