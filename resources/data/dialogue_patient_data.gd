extends PatientData
class_name DialoguePatientData

@export var patient_name : String = ""
@export var dialogue_options : PackedStringArray = []

func _init(reference : String = "", injuries : Dictionary = {}, patient_name : String = "", dialogue_options : Array[String] = []):
	super(reference, injuries)
	self.patient_name = patient_name
	self.dialogue_options = dialogue_options
