extends Node2D

@export var patient_data : PatientData

enum Limbs {
	HEAD,
	TORSO,
	LARM,
	RARM,
	LLEG,
	RLEG
}

var injuries : Array = []
var attempted_cures : Array = []

func _init(patient_data : PatientData = null) -> void:
	if patient_data:
		_populate(patient_data)

func _populate(patient_data : PatientData) -> void:
	self.patient_data = patient_data
	
	injuries.clear()
	injuries.resize(6)
	injuries.fill([])
	
	attempted_cures.clear()
	attempted_cures.resize(6)
	attempted_cures.fill([])
	
	for limb in patient_data.injuries.keys():
		for injury in patient_data.injuries[limb]:
			injuries[Limbs.get(limb)].append(Data.recall(injury))

func cure(limb : int, medicine : MedicineData) -> void:
	if medicine.reference == "amputation":
		if limb == Limbs.HEAD || limb == Limbs.TORSO:
			return
	
	for injury in injuries[limb]:
		if medicine.treatments.has("*"):
			_try_cure(limb, medicine)
			break
		elif medicine.treatments.has(injury.reference):
			_try_cure(limb, medicine, injury.reference)
			pass

func _try_cure(limb : int, medicine : MedicineData, injury : String = "*") -> void:
	var best_cure : Array = _get_best_cure(medicine.treatments.get(injury), limb)
	attempted_cures[limb].append(medicine)

	if best_cure.is_empty():
		return
	
	var rng = RandomNumberGenerator.new()
	if rng.randf() <= best_cure[0]:
		if injury == "*":
			injuries[limb].clear()
		else:
			injuries[limb].erase(Data.recall(injury))
	
	if best_cure[-1] is Array:
		for side_effect in best_cure[-1]:
			if rng.randf() <= side_effect[0]:
				if side_effect[1] == "shock" || side_effect[1] == "death":
					injuries[Limbs.HEAD].append(Data.recall(side_effect[1]))
				else:
					injuries[limb].append(Data.recall(side_effect[1]))

func _get_best_cure(cures : Array, limb : int) -> Array:
	var valid_cures = _get_valid_cures(cures, limb)
	var output : Array = []
	var output_percent : float = 0.
	
	for cure in valid_cures:
		if cure[0] > output_percent:
			output = cure
			output_percent = cure[0]
			break
	
	return output

func _get_valid_cures(cures : Array, limb : int) -> Array:
	var output : Array = []
	
	for cure in cures:
		var can_include = true
		
		for prereq in cure:
			if (prereq is String):
				if !attempted_cures[limb].contains(prereq):
					can_include = false
					break
		
		if can_include:
			output.append(cure)
	return output
