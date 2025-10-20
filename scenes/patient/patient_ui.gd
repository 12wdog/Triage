extends Control
class_name PatientUI

@onready var label : RichTextLabel = $Panel/RichTextLabel

func write(text : String):
	label.text = text
