extends Node2D
class_name Manager

var game := TriageGame.new()
var days : DayData = preload("res://presaved/day/days.tres")

func _ready() -> void:
	add_child(game)
	print(days.data)
	game.initialize_patient()
	game.initialize_random(days.data[0])
	
	for patient in game.backlog:
		print(patient)
	
	game.populate_bed(0)
	game.go_to_bed(0)
