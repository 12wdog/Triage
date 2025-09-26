@tool
extends EditorScript

const export : String = "res://presaved/booklet/book.tres"

var book := Book.new([
"• [b]HE[i] - High Effiquacy[/i][/b]
• [b]LE[i] - Low Effiquacy[/i][/b]
• [b]ME[i] - Medium Effiquacy[/i][/b]

[b][i]Bandage[/i][/b]
• [b]HE[/b] for [i]Light Bleeding[/i]
• [b]HE[/b] when used with [u]Serum[/u] for [i]Surface Infection[/i]
• [b]HE[/b] when used with [u]Surgery[/u] for [i]Severe Bleeding[/i]
• [b]ME[/b] for [i]Surface Bullet Wound[/i]
• [b]HE[/b] when used with [u]Surgery[/u] for [i]Surface Bullet Wound[/i]
",
	"This is another page"
])

func _run() -> void:
	ResourceSaver.save(book, export)

class Book extends Resource:
	@export var pages : PackedStringArray = []
	
	func _init(pages : Array[String] = []) -> void:
		self.pages = pages
