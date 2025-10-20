extends PatientData
class_name DialoguePatientData

@export var patient_name : String = ""
@export var dialogue_path : String = ""

func _init(reference : String = "", injuries : Dictionary = {}, patient_name : String = "", dialogue_path : String = ""):
	super(reference, injuries)
	self.patient_name = patient_name
	self.dialogue_path = dialogue_path
