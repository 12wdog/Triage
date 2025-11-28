extends Control
class_name EndOfDay

signal continue_signal()
signal exit_signal()

const cure = "PATIENTS CURED: "
const sent = "PATIENTS SENT AWAY: "
const killed = "PATIENTS KILLED: "

@onready var end_of_day_label : Label = $PanelContainer/MarginContainer/VBoxContainer/Label

@onready var cured_num  : Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/CureNum
@onready var sent_num   : Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/SentNum
@onready var killed_num : Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/KilledNum

@onready var continue_button : Button = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Continue
@onready var exit_button : Button = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Exit

func _ready() -> void:
	continue_button.pressed.connect(continue_signal.emit)
	exit_button.pressed.connect(exit_signal.emit)

func set_text(numbers : Array[int]) -> void:
	cured_num.text = cure + str(numbers[0])
	sent_num.text = sent + str(numbers[1])
	killed_num.text = killed + str(numbers[2])
