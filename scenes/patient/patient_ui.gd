extends CanvasLayer
class_name PatientUI

@onready var label : RichTextLabel = $Control/Panel/RichTextLabel

func write(text : String):
	label.text = text
