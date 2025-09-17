extends Node
class_name Game

var patient1 : Patient
var patient2 : Patient
var patient3 : Patient

var backlog : Array[PatientData] = []

func init(state : Array = []) -> void:
	if state.is_empty():
		begin(10, 4, 9)
	else:
		begin(state[0], state[1], state[2])

func begin(patients: int, min_injuries: int, max_injuries: int) -> void:
	backlog = []
	var rng := RandomNumberGenerator.new()
	for patient in range(patients):
		var num_injuries : int = rng.randi_range(min_injuries, max_injuries)
		backlog.append(PatientRandomizer.make(str(patient), num_injuries))
