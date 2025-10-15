extends Control

class_name Booklet

signal close_menu()

@onready var page_left  : RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Panel/HBoxContainer/MarginContainer/PanelLeft/PaperLeft
@onready var page_right : RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Panel/HBoxContainer/MarginContainer2/PanelRight/PaperRight
@onready var button_left  : Button = $MarginContainer/HBoxContainer/VBoxContainer/Panel2/HBoxContainer/ButtonLeft
@onready var button_right : Button = $MarginContainer/HBoxContainer/VBoxContainer/Panel2/HBoxContainer/ButtonRight
@onready var clipboard : TextEdit = $MarginContainer/HBoxContainer/Panel/Clipboard
@onready var close_button : Button = $CloseButton

const book_data = [
"[b][i]Bandage[/i][/b]
• [b]HE[/b] for [i]Light Bleeding[/i]
• [b]LE[/b] for [i]Heavy Bleeding[/i]
	• [b]HE[/b] when used with [u]Stitches[/u]
• [b]LE[/b] when used with [u]Serum[/u] for [i]Infection[/i]
	• [b]ME[/b] when used with [u]Antibiotics[/u]
	• [b]HE[/b] when used with [u]Serum[/u] and [u]Antibiotics[/u]
• [b]LE[/b] for [i]Bullet Wound[/i]
	• [b]ME[/b] when used with [u]Tongs[/u]
	• [b]HE[/b] when used with [u]Tongs[/u] and [u]Stitches[/u]
• [b]HE[/b] when used with [u]Serum[/u] for [i]Second Degree Burns[/i]

[b][i]Serum[/i][/b]
• [b]HE[/b] for [i]First Degree Burns[/i]

[b][i]Stitches[/i][/b]
• [b]ME[/b] when used with [u]Surgery[/u] for [i]Internal Bleeding[/i]
• [b]ME[/b] for [i]Bullet Wound[/i]
	• [b]ME[/b] when used with [u]Tongs[/u]
",
	"[b][i]Antibiotics[/i][/b]
• [b]LE[/b] for [i]Infection[/i]

[b][i]Surgery[/i][/b]
• [b]ME[/b] for [i]Broken Bone[/i]
• [b]ME[/b] for [i]Necrosis[/i]
	• [b]HE[/b] when used with [u]Antibiotics[/u]
• [b]LE[/b] for [i]Shock[/i]
	• [b]WARNING![/b] High risk of [b]PATIENT DEATH[/b]

[b][i]Bone Saw[/i][/b]
• [b]GUARANTEED TO CURE ANYTHING, BUT HIGH RISK OF SHOCK OR DEATH[/b] 

[b][i]Painkiller[/i][/b]
• [b]LE[/b] for [i]Light Bleeding[/i], [i]Infection[/i], and [i]Bullet Wounds[/i], 
	• [b]ME[/b] If used again. [b]RISK OF OVERDOSE![/b]
• [b]ME[/b] for [i]Shock[/i]
	• [b]HE[/b] If used again. [b]RISK OF OVERDOSE![/b]
",
"This is a third page"
]

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
	if book_data.size() < current_page + 1:
		page_right.text = book_data[current_page + 1]
	else:
		page_right.text = ""
