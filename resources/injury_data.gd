extends Resource
class_name InjuryData

@export var reference : String = ""
@export var injury_name : String = ""
@export var asset_paths : PackedStringArray = []

func _init(reference : String = "", injury_name : String = "", asset_paths : Array[String] = []):
	self.reference = reference
	self.injury_name = injury_name
	self.asset_paths = asset_paths
