@tool
extends EditorScript

const injury_path = "res://presaved/injuries/"
const medicine_path = "res://presaved/medicine/"

var injury_array = [
	InjuryData.new("Light Bleeding"),
	InjuryData.new("Heavy Bleeding"),
	InjuryData.new("Infection"),
	InjuryData.new("Bullet Wound"),
	InjuryData.new("First Degree Burn"),
	InjuryData.new("Second Degree Burn"),
	InjuryData.new("Broken Limb"),
	InjuryData.new("Shock")
]
var medicine_array = [
	MedicineData.new("Bandage", {
		"Light Bleeding": [
			[.8, [
				["Infection", .3]
			]]
		],
		"Heavy Bleeding": [
			[.3],
			["Stitches", .7, [
				["Infection", .3],
				["Shock", .1]
			]]
		],
		"Severe Burn": [
			["Salve", .7, [
				["Infection", .5]
			]]
		],
		"Infection": [
			["Antiseptic", .7]
		],
		"Bullet Wound": [
			[.5, [
				["Infection", .3]
			]],
			["Stitches", .8, [
				["Infection", .1]
			]]
		]
	})
]

func _run():
	
	for injury in injury_array:
		ResourceSaver.save(injury, injury_path + injury.injury_name + ".tres")
	
	for medicine in medicine_array:
		ResourceSaver.save(medicine, medicine_path + medicine.medicine_name + ".tres")
