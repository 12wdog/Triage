extends Node
class_name TriageGame

@onready var rng := RandomNumberGenerator.new()

var patients : Array[Patient] = []
@onready var display : PatientUI = preload("res://scenes/patient/patient_ui.tscn").instantiate()

var backlog : Array[PatientData] = []

func initialize_patient() -> void:
	for i in range(3):
		var patient : Patient = load("res://scenes/patient/patient.tscn").instantiate()
		patients.append(patient)
		patient.visible = false
		patient.display.connect(write_to_display)
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
	backlog.remove_at(0)

func go_to_bed(bed : int) -> void:
	for patient in patients:
		patient.visible = false
	
	patients[bed].visible = true

func write_to_display(text : String) -> void:
	display.write(text)
