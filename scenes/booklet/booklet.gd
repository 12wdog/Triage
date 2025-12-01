extends Control

class_name Booklet

signal close_menu()

@onready var page_left  : RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/MarginContainer/PanelLeft/PaperLeft
@onready var page_right : RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/MarginContainer2/PanelRight/PaperRight
@onready var button_left  : Button = $MarginContainer/HBoxContainer/VBoxContainer/Panel2/HBoxContainer/ButtonLeft
@onready var button_right : Button = $MarginContainer/HBoxContainer/VBoxContainer/Panel2/HBoxContainer/ButtonRight
@onready var clipboard : TextEdit = $MarginContainer/HBoxContainer/Panel/Clipboard
@onready var close_button : Button = $CloseButton

var book_data = preload("res://presaved/booklet/book.tres").pages

var current_page := 0

func _ready():
	button_left.pressed.connect(page_dec)
	button_right.pressed.connect(page_inc)
	close_button.pressed.connect(close_menu.emit)

func page_dec():
	if current_page <= 0: return
	current_page = current_page - 2
	
	page_left.text = book_data[current_page]
	page_right.text = book_data[current_page + 1]

func page_inc():
	if current_page >= book_data.size() / 2: return
	current_page = current_page + 2
	
	page_left.text = book_data[current_page]
	if current_page + 1 < book_data.size():
		page_right.text = book_data[current_page + 1]
	else:
		page_right.text = ""
