extends Resource
class_name Data

# --- Injuries ---
const broken_limb      : InjuryData = preload("res://presaved/injuries/broken_limb.tres")
const bullet           : InjuryData = preload("res://presaved/injuries/bullet.tres")
const burn_one         : InjuryData = preload("res://presaved/injuries/burn_one.tres")
const burn_two         : InjuryData = preload("res://presaved/injuries/burn_two.tres")
const death            : InjuryData = preload("res://presaved/injuries/death.tres")
const heavy_bleed      : InjuryData = preload("res://presaved/injuries/heavy_bleed.tres")
const infection        : InjuryData = preload("res://presaved/injuries/infection.tres")
const internal_bleed   : InjuryData = preload("res://presaved/injuries/internal_bleed.tres")
const light_bleed      : InjuryData = preload("res://presaved/injuries/light_bleed.tres")
const necrosis         : InjuryData = preload("res://presaved/injuries/necrosis.tres")
const shock            : InjuryData = preload("res://presaved/injuries/shock.tres")

# --- Medicine ---
const amputation       : MedicineData = preload("res://presaved/medicine/amputation.tres")
const antibiotic       : MedicineData = preload("res://presaved/medicine/antibiotic.tres")
const antiseptic       : MedicineData = preload("res://presaved/medicine/antiseptic.tres")
const bandage          : MedicineData = preload("res://presaved/medicine/bandage.tres")
const painkiller       : MedicineData = preload("res://presaved/medicine/painkiller.tres")
const stitches         : MedicineData = preload("res://presaved/medicine/stitches.tres")
const surgery          : MedicineData = preload("res://presaved/medicine/surgery.tres")
const tongs            : MedicineData = preload("res://presaved/medicine/tongs.tres")

# Registry for string lookup
const _REGISTRY := {
	"broken_limb": broken_limb,
	"bullet": bullet,
	"burn_one": burn_one,
	"burn_two": burn_two,
	"death": death,
	"heavy_bleed": heavy_bleed,
	"infection": infection,
	"internal_bleed": internal_bleed,
	"light_bleed": light_bleed,
	"necrosis": necrosis,
	"shock": shock,

	"amputation": amputation,
	"antibiotic": antibiotic,
	"antiseptic": antiseptic,
	"bandage": bandage,
	"painkiller": painkiller,
	"stitches": stitches,
	"surgery": surgery,
	"tongs": tongs,
	
}

static func recall(name: String) -> Resource:
	return _REGISTRY.get(name)
