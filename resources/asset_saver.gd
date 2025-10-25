@tool
extends EditorScript

const injury_path = "res://presaved/injuries/"
const medicine_path = "res://presaved/medicine/"
const patient_path = "res://presaved/patients/"
const day_path = "res://presaved/day/days.tres"

var injury_array = [
	InjuryData.new("light_bleed", "Light Bleeding"),
	InjuryData.new("heavy_bleed", "Heavy Bleeding"),
	InjuryData.new("internal_bleed", "Internal Bleeding"),
	InjuryData.new("infection", "Infection"),
	InjuryData.new("bullet", "Bullet Wound"),
	InjuryData.new("burn_one", "First Degree Burn"),
	InjuryData.new("burn_two", "Second Degree Burn"),
	InjuryData.new("broken_limb", "Broken Limb"),
	InjuryData.new("shock", "Shock"),
	InjuryData.new("necrosis", "Necrosis"),
	InjuryData.new("death", "Death", 1)
]

var medicine_array = [
	MedicineData.new("bandage", "Bandage", {
		"light_bleed": [
			[0.8, [0.3, "infection"]]
		],
		"heavy_bleed": [
			[0.3, [0.3, "infection"], [0.1, "shock"]],
			[0.7, "stitches", [0.2, "infection"], [0.1, "shock"]]
		],
		"burn_two": [
			[0.7, "antiseptic"]
		],
		"infection": [
			[0.4, "antiseptic"],
			[0.5, "antibiotic"],
			[0.7, "antiseptic", "antibiotic"]
		],
		"bullet": [
			[0.2, [0.5, "infection"]],
			[0.5, "tongs", [0.4, "infection"]],
			[0.8, "tongs", "stitches"]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("antiseptic", "Serum", {
		"burn_one": [
			[0.8]
		],
		"burn_two": [
			[0.0]
		],
		"infection": [
			[0.0],
			[0.0, "antibiotic"]
		]
	},
	1,
	true,
	"res://textures/medicine/Serum.png"
	),
	MedicineData.new("stitches", "Stitches", {
		"heavy_bleed": [
			[0.0]
		],
		"internal_bleed": [
			[0.45, "surgery", [0.3, "shock"]]
		],
		"bullet": [
			[0.5, [0.3, "infection"]],
			[0.7, "tongs", [0.15, "infection"]]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("antibiotic", "Antibiotics", {
		"infection": [
			[0.3]
		],
		"necrosis": [
			[0.0]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("surgery", "Surgical Tools", {
		"broken_limb": [
			[0.4],
			[0.7, "splint"]
		],
		"necrosis": [
			[0.4, [0.6, "shock"]],
			[0.8, "antibiotic"]
		],
		"shock": [
			[0.3, [0.6, "death"]]
		]
	},
	2,
	false,
	""
	),
	MedicineData.new("tongs", "Tongs", {
		"bullet": [
			[0.0]
		]
	},
	2,
	false,
	""
	),
	MedicineData.new("painkiller", "Painkillers", {
		"light_bleed": [
			[0.4],
			[0.7, "painkiller", [0.3, "death"]]
		],
		"infection": [
			[0.3],
			[0.6, "painkiller", [0.3, "death"]]
		],
		"bullet": [
			[0.3],
			[0.6, "painkiller", [0.3, "death"]]
		],
		"shock": [
			[0.6],
			[0.9, "painkiller", [0.3, "death"]]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("amputation", "Bone Saw", {
		"*": [
			[1.0, [0.8, "shock"], [0.6, "death"]]
		]
	},
	2,
	false,
	""
	),
	MedicineData.new("splint", "Splint", {
		"broken_limb": [
			[0.4]
		]
	},
	2,
	false,
	""
	)
]
var patient_array = [
	DialoguePatientData.new("tut", {
		"LARM": [Data.recall("bullet")]
	}, 
	"patient", 
	"res://dialogue/dialogue_text/tutorial.txt")
]

var day : DayData = DayData.new([
	[1, 1, 2],
	[2, 1, 4],
	[4, 2, 4]
])

func _run():
	
	for injury in injury_array:
		ResourceSaver.save(injury, injury_path + injury.reference + ".tres")
	
	for medicine in medicine_array:
		ResourceSaver.save(medicine, medicine_path + medicine.reference + ".tres")
	
	for patient in patient_array:
		ResourceSaver.save(patient, patient_path + patient.reference + ".tres")
	
	ResourceSaver.save(day, day_path)
