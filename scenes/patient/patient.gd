extends Node2D
class_name Patient

@export var patient_data : PatientData

var dead : bool = false

enum Limbs {
	HEAD,
	TORSO,
	LARM,
	RARM,
	LLEG,
	RLEG
}

enum Result {
	CLEAR,
	NOCLEAR,
	UNABLE,
	DEAD
}

var injuries : Array = []
var attempted_cures : Array = []

func _init(patient_data : PatientData = null) -> void:
	if patient_data:
		populate(patient_data)

func populate(patient_data : PatientData) -> void:
	self.patient_data = patient_data
	
	injuries.clear()
	injuries.resize(6)
	for i in range(6):
		injuries[i] = []
	
	attempted_cures.clear()
	attempted_cures.resize(6)
	for i in range(6):
		attempted_cures[i] = []
	
	for limb in patient_data.injuries.keys():
		for injury in patient_data.injuries[limb]:
			injuries[Limbs.get(limb)].append(injury)

func cure(limb : int, medicine : MedicineData) -> Result:
	if dead:
		return Result.DEAD

	if medicine.reference == "amputation" and (limb == Limbs.HEAD or limb == Limbs.TORSO):
		return Result.UNABLE # no.

	var result := Result.CLEAR
	var current_injuries = injuries[limb].duplicate()	# <-- snapshot

	for injury in current_injuries:
		if medicine.treatments.has("*"):
			return _try_cure(limb, medicine)
		elif medicine.treatments.has(injury.reference):
			var temp = _try_cure(limb, medicine, injury.reference)
			if temp != Result.CLEAR:
				result = temp
			if result == Result.DEAD or result == Result.UNABLE:
				return result

	return result

func lethal(injury : InjuryData) -> Result:
	var rng := RandomNumberGenerator.new()
	if rng.randf() <= injury.lethality:
		return Result.DEAD
	
	return Result.CLEAR

func _try_cure(limb : int, medicine : MedicineData, injury : String = "*") -> Result:
	var best_cure : Array = _get_best_cure(medicine.treatments.get(injury), limb)
	attempted_cures[limb].append(medicine)

	if best_cure.is_empty():
		return Result.UNABLE
	
	var rng = RandomNumberGenerator.new()
	var result : Result
	if rng.randf() <= best_cure[0]:
		if injury == "*":
			injuries[limb].clear()
		else:
			injuries[limb].erase(Data.recall(injury))
		result = Result.CLEAR
	else: result = Result.NOCLEAR
	
	if best_cure[-1] is Array:
		var side_effect_result = _add_side_effect(best_cure[-1][0], Data.recall(best_cure[-1][1]), limb)
		if side_effect_result == Result.DEAD:
			return side_effect_result
	
	return result

func _get_best_cure(cures : Array, limb : int) -> Array:
	var valid_cures = _get_valid_cures(cures, limb)
	var output : Array = []
	var output_percent : float = 0.
	
	for cure in valid_cures:
		if cure[0] > output_percent:
			output = cure
			output_percent = cure[0]
	
	return output

func _get_valid_cures(cures : Array, limb : int) -> Array:
	var output : Array = []
	
	for cure in cures:
		var can_include = true
		
		for prereq in cure:
			if (prereq is String):
				if !attempted_cures[limb].has(prereq):
					can_include = false
					break
		
		if can_include:
			output.append(cure)
	return output

func _add_side_effect(chance : float, side_effect: InjuryData, limb : int) -> Result:
	
	var rng := RandomNumberGenerator.new()
	if rng.randf() > chance:
		return Result.CLEAR
	
	if side_effect.reference == "death" || side_effect.reference == "shock":
		if side_effect.reference == "death":
			dead = true
			return Result.DEAD
		
		if injuries[Limbs.HEAD].contains(side_effect):
			var result = lethal(side_effect)
			return result
		else:
			injuries[Limbs.HEAD].append(side_effect)
			return Result.CLEAR
	
	if injuries[limb].has(side_effect):
		var result = lethal(side_effect)
		return result
	else:
		injuries[limb].append(side_effect)
		return Result.CLEAR
	
func _to_string() -> String:
	var limb_names := Limbs.keys()   # ["HEAD", "TORSO", "LARM", ...]
	var output := "Patient(%s)\n" % patient_data.reference

	for i in limb_names.size():
		var limb_name = limb_names[i]

		var injury_list : Array = []
		if i < injuries.size():
			for injury in injuries[i]:
				injury_list.append(injury.injury_name if injury else str(injury))

		var cure_list : Array = []
		if i < attempted_cures.size():
			for cure in attempted_cures[i]:
				cure_list.append(cure.medicine_name if cure else str(cure))

		output += "  %s:\n" % limb_name
		output += "    Injuries: %s\n" % ("[none]" if injury_list.is_empty() else ", ".join(injury_list))
		output += "    Attempted cures: %s\n" % ("[none]" if cure_list.is_empty() else ", ".join(cure_list))
	return output
