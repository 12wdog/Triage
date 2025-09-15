@tool
extends EditorScript

const injury_path = "res://presaved/injuries/"
const medicine_path = "res://presaved/medicine/"

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
	InjuryData.new("necrosis", "Necrosis")
]
var medicine_array = [
	MedicineData.new("bandage", "Bandage", {
		"light_bleed": [
			[.8, [
				["infection", .3]
			]]
		],
		"heavy_bleed": [
			[.3, [
				["infection", .3],
				["shock", .1]
			]],
			["stitches", .7, [
				["infection", .2],
				["shock", .1]
			]]
		],
		"burn_two": [
			["antiseptic", .7]
		],
		"infection": [
			["antiseptic", .4],
			["antibiotic", .5],
			["antiseptic", "antibiotic", .7]
		],
		"bullet": [
			[.2, [
				["infection", .5]
			]],
			["tongs", .5, [
				["infection", .4]
			]],
			["tongs", "stitches", .8]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("antiseptic", "Serum", {
		"burn_one": [
			[.8]
		],
		"burn_two": [
			[.0]
		],
		"infection": [
			[.0],
			["antibiotic", .0]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("stitches", "Stitches", {
		"heavy_bleed": [
			[.0]
		],
		"internal_bleed": [
			["surgery", .45, [
				["shock", .3]
			]]
		],
		"bullet": [
			[.5, [
				["infection", .3]
			]],
			["tongs", .7, [
				["infection", .15]
			]]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("antibiotic", "Antibiotics", {
		"infection": [
			[.3]
		],
		"necrosis": [
			[.0]
		]
	},
	1,
	true,
	""
	),
	MedicineData.new("surgery", "Surgical Tools", {
		"broken_bone": [
			[.4],
			["splint", .7]
		],
		"necrosis": [
			[.4, [
				["shock", .6]
			]],
			["antibiotic", .8]
		],
		"shock": [
			[.3, [
				["death", .6]
			]]
		]
	},
	2,
	false,
	""
	),
	MedicineData.new("tongs", "Tongs", {
		"bullet": [
			[.0]
		]
	},
	2,
	false,
	""
	),
	MedicineData.new("painkiller", "Painkillers", {
		
	})
]

func _run():
	
	for injury in injury_array:
		ResourceSaver.save(injury, injury_path + injury.reference + ".tres")
	
	for medicine in medicine_array:
		ResourceSaver.save(medicine, medicine_path + medicine.reference + ".tres")
