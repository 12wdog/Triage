extends Resource
class_name PatientData

@export var reference : String = ""
@export var injuries : Dictionary = {}

func _init(reference : String = "", injuries : Dictionary = {}):
	self.reference = reference
	self.injuries = injuries
