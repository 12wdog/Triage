@tool
extends EditorScript

const export : String = "res://presaved/booklet/book.tres"

var book := Book.new([
	"This is a page",
	"This is another page"
])

func _run() -> void:
	ResourceSaver.save(book, export)

class Book extends Resource:
	@export var pages : PackedStringArray = []
	
	func _init(pages : Array[String] = []) -> void:
		self.pages = pages
