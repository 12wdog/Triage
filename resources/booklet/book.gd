extends Resource

class_name Book 


@export var pages : Array[String] = []

func _init(pages : Array[String] = []) -> void:
	self.pages = pages
