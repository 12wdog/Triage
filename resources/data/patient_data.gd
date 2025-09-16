extends Resource
class_name PatientData

@export var reference : String = ""
@export var injuries : Dictionary = {}

func _init(reference : String = "", injuries : Dictionary = {}):
	self.reference = reference
	self.injuries = injuries


func _to_string() -> String:
	var output := "Patient(%s)\n" % reference

	for limb in injuries.keys():
		var injury_list : Array = injuries[limb]
		if injury_list.is_empty():
			output += "  %s: [no injuries]\n" % limb
		else:
			output += "  %s: %s\n" % [limb, ", ".join(injury_list)]
	
	return output
