extends Control

class_name MainMenu

signal new_game()
signal cont()
signal exit()

@onready var new_game_button : Button = $CenterContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/NewGame
@onready var continue_button : Button = $CenterContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/Continue
@onready var exit_button : Button = $CenterContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/Exit

func _ready() -> void:
	new_game_button.pressed.connect(new_game.emit)
	continue_button.pressed.connect(cont.emit)
	exit_button.pressed.connect(exit.emit)
