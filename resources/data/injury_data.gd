extends Resource
class_name InjuryData

@export var reference : String = ""
@export var injury_name : String = ""
@export var lethality : float = 0.0
@export var asset_paths : PackedStringArray = []

func _init(reference : String = "", injury_name : String = "", lethality : float = 0.0, asset_paths : Array[String] = []):
	self.reference = reference
	self.injury_name = injury_name
	self.lethality = lethality
	self.asset_paths = asset_paths

func _to_string() -> String:
	return injury_name
