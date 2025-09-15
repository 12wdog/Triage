extends Resource
class_name InjuryData

@export var injury_name : String = ""
@export var asset_paths : PackedStringArray = []

func _init(injury_name : String, asset_paths : Array[String] = []):
	self.injury_name = injury_name
	self.asset_paths = asset_paths
