extends Node2D


func _ready() -> void:
	var test : PatientData = PatientRandomizer.make("test", 5, 6)
	
	print(test._to_string())
	var patient : Patient = Patient.new(test)
	
	print(patient)
	var result = patient.cure(Patient.Limbs.RARM, Data.recall("bandage"))
	print(Patient.Result.find_key(result))
	print(patient)
