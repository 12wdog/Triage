extends Resource
class_name PatientRandomizer

const limb_weight : PackedFloat32Array = [.3, .15, .7, .7, .7, .7]

static func make(reference: String, injury_number : int, seed : int = -1) -> PatientData:
	var rng := RandomNumberGenerator.new()
	print(rng.seed)
	var registry_size : int = Data._REGISTRY.size()
	if seed != -1:
		rng.seed = seed
	
	var patient := PatientData.new(reference)
	
	for i in range(injury_number):
		var limb = rng.rand_weighted(limb_weight)
		
		var key = Patient.Limbs.find_key(limb)

		var injury
		while true:
			injury = Data._REGISTRY.values().get(rng.randi_range(0, registry_size -1))
			if injury is InjuryData:
				if injury.reference == "shock" || injury.reference == "death":
					continue
				if limb == Patient.Limbs.HEAD && (injury.reference == "bullet" || injury.reference == "broken_bone"):
					continue
				if patient.injuries.has(key) && patient.injuries[key].has(injury):
					continue
				break
		
		if not patient.injuries.has(key):
			patient.injuries[key] = []
		
		patient.injuries[key].append(injury)
	
	return patient
