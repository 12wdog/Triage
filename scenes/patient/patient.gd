extends Node2D
class_name Patient

signal display(text : String)
signal limb_click(limb : int, id : int)
signal cured(id : int)

var id : int
var is_dialogue : bool = false
var dialogue : String = ""

@export var patient_data : PatientData

@onready var head = $PatientVisual/HEAD
@onready var torso = $PatientVisual/TORSO
@onready var larm = $PatientVisual/LARM
@onready var rarm = $PatientVisual/RARM
@onready var lleg = $PatientVisual/LLEG
@onready var rleg = $PatientVisual/RLEG

var dead : bool = false
var selected_area : Limbs
var hovered: Area2D

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

func _init(data : PatientData = null) -> void:
	if data:
		patient_data = data
		populate()

func _ready():
	setup()

func setup():
	for limb in [head, torso, larm, rarm, lleg, rleg]:
		if limb.input_event.is_connected(input_event):
			limb.input_event.disconnect(input_event)
		limb.input_event.connect(func(_viewport, event, _shape_idx): input_event(limb, event))


func populate() -> void:

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
	
	if patient_data is DialoguePatientData:
			is_dialogue = true
			dialogue = patient_data.dialogue_path


func cure(limb : int, medicine : MedicineData) -> Result:
	if dead:
		return Result.DEAD

	print(Limbs.find_key(limb))

	if medicine.reference == "amputation" and (limb == Limbs.HEAD or limb == Limbs.TORSO):
		return Result.UNABLE # cannot amputate head/torso

	var result := Result.UNABLE
	var current_injuries = injuries[limb].duplicate()	# snapshot of current injuries

	# Track whether the medicine was actually applied
	var applied := false

	for injury in current_injuries:
		print("Checking injury: ", injury)

		if medicine.treatments.has("*"):
			# universal medicine, always attempt
			result = _try_cure(limb, medicine)
			applied = true

		elif medicine.treatments.has(injury.reference):
			var temp = _try_cure(limb, medicine, injury.reference)
			applied = true

			if temp != Result.CLEAR:
				result = temp
			else:
				result = Result.CLEAR

			if result == Result.UNABLE:
				print("UNABLE")
				return result
	
	
	
	# Only log as attempted if something was actually applied
	if applied:
		attempted_cures[limb].append(medicine)
		print("ABLE")
		is_cured()
		return result
	else:
		print("Medicine has no effect on this injury")
		return Result.UNABLE

func lethal(injury : InjuryData) -> Result:
	var rng := RandomNumberGenerator.new()
	if rng.randf() <= injury.lethality:
		return Result.DEAD
	
	return Result.CLEAR

func input_event(limb: Area2D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if hovered != limb:
			hovered = limb
			area_entered(limb)
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.pressed \
	and not event.double_click:
		limb_click.emit(Limbs.get(limb.name), id)
		pass
	
func area_entered(area : Area2D) -> void:
	selected_area = Limbs.get(area.name)
	_update_display(selected_area)

func _try_cure(limb : int, medicine : MedicineData, injury : String = "*") -> Result:
	var best_cure : Array = _get_best_cure(medicine.treatments.get(injury), limb)
	if best_cure.is_empty():
		return Result.UNABLE
	
	print(best_cure)
	
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
	print(valid_cures)
	var output : Array = []
	var output_percent : float = -1
	
	for _cure in valid_cures:
		if _cure[0] > output_percent:
			output = _cure
			output_percent = _cure[0]
	
	return output

func _get_valid_cures(cures: Array, limb: int) -> Array:
	var output: Array = []
	
	for _cure in cures:
		var can_include := true
		
		print(_cure)
		for prereq in _cure:
			if prereq is String:
				print("Checking prereq: %s" % prereq)
				print("Attempted cures for limb: ", attempted_cures[limb])
				
				var found := false
				for attempted in attempted_cures[limb]:
					if attempted.reference == prereq:
						found = true
						break
				
				if !found:
					can_include = false
					break
		
		print("Can include? %s" % can_include)
		if can_include:
			output.append(_cure)
	
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
			for _cure in attempted_cures[i]:
				cure_list.append(_cure.medicine_name if _cure else str(cure))

		output += "  %s:\n" % limb_name
		output += "    Injuries: %s\n" % ("[none]" if injury_list.is_empty() else ", ".join(injury_list))
		output += "    Attempted cures: %s\n" % ("[none]" if cure_list.is_empty() else ", ".join(cure_list))
	return output

func _update_display(limb : int) -> void:
	
	#var limb_injuries = injuries[limb]
	#var limb_cures = attempted_cures[limb]
	
	var text : String = "Limb: [b]%s[/b]\nInjuries:\n" % Limbs.find_key(limb)
	for injury in injuries[limb]:
		text += "[color=red] • %s[/color]\n" % injury
	
	if injuries[limb].is_empty():
		text += "[color=green] • NONE[/color]\n"
	
	text += "\nAttempted Treatments:\n"
	for treatment in attempted_cures[limb]:
		text += "[color=green] • %s[/color]\n" % treatment
	
	if attempted_cures[limb].is_empty():
		text += " • NONE\n"
	
	display.emit(text)

func is_cured() -> void:
	print("Checking if cured")
	for limb_injuries in injuries:
		if not limb_injuries.is_empty():
			return   # still injured, stop
	print("is cured")
	cured.emit(id)

func _physics_process(_delta):
	if patient_data:
		$PatientVisual.visible = true
	else:
		$PatientVisual.visible = false
