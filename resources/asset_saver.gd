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
	"res://textures/medicine/Bandage.png"
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
	"res://textures/medicine/Surgery.png"
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
	"res://textures/medicine/Antibiotic.png"
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
	"res://textures/medicine/Scalpel.png"
	),
	MedicineData.new("tongs", "Tongs", {
		"bullet": [
			[0.0]
		]
	},
	2,
	false,
	"res://textures/medicine/Tongs.png"
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
	"res://textures/medicine/Painkillers.png"
	),
	MedicineData.new("amputation", "Bone Saw", {
		"*": [
			[1.0, [0.8, "shock"], [0.6, "death"]]
		]
	},
	2,
	false,
	"res://textures/medicine/Bonesaw.png"
	),
	MedicineData.new("splint", "Splint", {
		"broken_limb": [
			[0.4]
		]
	},
	2,
	false,
	"res://textures/medicine/Splint.png"
	)
]
var patient_array = [
	DialoguePatientData.new("tut", {
		"LARM": [Data.recall("bullet")]
	}, 
	"patient", 
	"res://dialogue/dialogue_text/tutorial.txt"),
	DialoguePatientData.new("addict", {
		"RARM": [Data.recall("infection")]
	}, 
	"John", 
	"res://dialogue/dialogue_text/addict1.txt"),
	DialoguePatientData.new("elderly", {
		"LARM": [Data.recall("light_bleed")]
	}, 
	"Jeffery", 
	"res://dialogue/dialogue_text/elderly1.txt"),
	DialoguePatientData.new("opportunist", {
		"RARM": [Data.recall("burn_two")]
	}, 
	"Michael", 
	"res://dialogue/dialogue_text/opportunist1.txt"),
	DialoguePatientData.new("stoic", {
		"TORSO": [Data.recall("broken_limb")]
	}, 
	"Ben", 
	"res://dialogue/dialogue_text/stoic1.txt"),
	DialoguePatientData.new("veteran", {
		"LLEG": [Data.recall("broken_limb")]
	}, 
	"David", 
	"res://dialogue/dialogue_text/veteran1.txt")
]

var day : DayData = DayData.new([
	[preload("res://presaved/patients/tut.tres") as DialoguePatientData],
	[[2, 2, 1]],
	[[1, 2, 2], preload("res://presaved/patients/addict.tres") as DialoguePatientData, [1, 2, 2]], 
	[[2, 3, 2], preload("res://presaved/patients/opportunist.tres") as DialoguePatientData],
	[[5, 5, 4]],
	[[1, 5, 5], preload("res://presaved/patients/stoic.tres") as DialoguePatientData, [5,7,4]]
])

func _run():
	
	for injury in injury_array:
		ResourceSaver.save(injury, injury_path + injury.reference + ".tres")
	
	for medicine in medicine_array:
		ResourceSaver.save(medicine, medicine_path + medicine.reference + ".tres")
	
	for patient in patient_array:
		ResourceSaver.save(patient, patient_path + patient.reference + ".tres")
	
	ResourceSaver.save(day, day_path)
