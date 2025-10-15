extends Resource

class_name Book 


@export var pages : PackedStringArray = []

func _init(pages : Array[String] = []) -> void:
	self.pages = pages
