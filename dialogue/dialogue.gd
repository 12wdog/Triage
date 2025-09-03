extends Node
class_name Dialogue

signal cont();

func read_file(path : String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var lines = content.split("/r/n")
		for i in range(lines.size()):
			lines[i] = lines[i].strip_edges()
		
		await read(lines)

func read(dialogue : Array[String]) -> void:
	for line in dialogue:
		await _read_line(line)
		await cont

func _read_line(line : )
