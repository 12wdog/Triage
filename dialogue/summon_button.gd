extends Button

class_name SummonButton

signal function(funct : String)

var storedFunc : String

func _init(funct : String) -> void:
	storedFunc = funct

func _pressed() -> void:
	function.emit(storedFunc)
