extends Node

class_name FileOpener

static func getFile(filepath : String) -> PackedStringArray:
	
	var f = FileAccess.open(filepath, FileAccess.READ)
	
	var regex = RegEx.new()
	regex.compile("\\S+\\N+")
	
	var output : PackedStringArray = []
	
	for pattern in regex.search_all(f.get_as_text()):
		output.append(pattern.get_string().trim_suffix("\r"))
	
	return output
