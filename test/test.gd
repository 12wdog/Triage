extends Node2D

@onready var dialogue := Dialogue.new()

func _ready():
	await dialogue.read(["This is a line", "This is another line", "Woah! A third line!"])

func _physics_process(delta):
	if Input.is_action_just_pressed("dialogue_continue"):
		dialogue.cont.emit()
