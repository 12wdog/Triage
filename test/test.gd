extends Control

@onready var dialogue : Dialogue = $Dialogue

func _ready() -> void:
	dialogue.read_file("res://dialogue/test_dialogue.txt")
	dialogue.start()
