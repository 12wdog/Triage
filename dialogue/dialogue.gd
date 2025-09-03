extends Node
class_name Dialogue

signal cont();

var dialogue : PackedStringArray

var functions: Dictionary
var variables: Dictionary
var characters: Dictionary
var backgrounds: Dictionary
var sounds: Dictionary
var musics: Dictionary
var jumppoints: Dictionary



func read_file(path : String) -> void:
	dialogue = FileOpener.getFile(path)
	
	_get_functions()
	
	if functions.has("#VARS"):
		_get_vars()
	if functions.has("#CHARS"):
		_get_chars()
	if functions.has("#SOUNDS"):
		_get_sounds()

func start() -> void:
	await _read(functions.get("#MAIN") + 1)

func _read(line : int) -> int:
	while(true):
		
		var currentLine :String = dialogue[line]
		if currentLine == "[END]":
			return line
		if currentLine[0] == "{":
			await _run_command(line)
			line += 1
		elif currentLine[0] == "[":
			line = await _run_intern_function(line)
		else:
			_write(currentLine)
			line += 1
			await cont
	
	return 0;

func _run_command(line: int) -> void:
	pass

func _run_intern_function(line: int) -> int:
	return line;

func _write(line: String) -> void:
	pass
	#if line.contains('{'):
		#var charPosition = line.find('{')
		#
		#while charPosition < line.length():
			#var varName : String = line[charPosition]
			#while line[charPosition] != '}':
				#charPosition += 1
				#varName += line[charPosition]
			#
			#line = line.replace(varName, '[color=' + variableColor + ']' + str(variables.get(varName.substr(1, varName.length() - 2)).data) + '[/color]')
			#
			#if line.contains('{'):
				#charPosition = line.find('{')
			#else:
				#break
	#
	#text.text = '[center]' + line



func _get_functions() -> void:
	
	var funcCount := 0
	var lineNum = 0
	for line in dialogue:
		if line[0] == '[':
			if funcCount == 0:
				functions.get_or_add(line.substr(1, line.length() - 2), lineNum)
				#functions.append(Function.new(line.substr(1, line.length() - 2), lineNum))
				
			if line == "[END]":
				funcCount -=1
			else:
				funcCount +=1
			
		lineNum += 1
	
func _get_vars() -> void:
	var variablesFunction : int = functions.get("#VARS") + 1
	
	while dialogue[variablesFunction] != "[END]":
		
		var properties := _split_command(dialogue[variablesFunction])
		variables.get_or_add(properties[0], Variable.new(properties))
		variablesFunction += 1
	
	
	variables.get_or_add("ME", Variable.new(["ME", "STRING", "BLANK"]))

func _get_chars() -> void:
	var characterFunction : int = functions.get("#CHARS") + 1
	
	while dialogue[characterFunction] != "[END]":
		var charVar := _split_command(dialogue[characterFunction])
		characters.get_or_add(charVar[0], charVar[1])
		characterFunction += 1

func _get_sounds() -> void:
	var soundsFunction : int = functions.get("#SOUNDS") + 1
	
	while dialogue[soundsFunction] != "[END]":
		var soundVar := _split_command(dialogue[soundsFunction])
		sounds.get_or_add(soundVar[0], soundVar[1])
		soundsFunction += 1
	
func _split_command(command : String) -> Array[String]:
	var output : Array[String] = []
	
	var pos := 0
	for c in command:
		if c == '}':
			break
		
		pos += 1
	
	output.append(command.substr(1, pos - 1))
	var remaining := command.substr(pos+1).strip_edges()
	remaining = remaining.substr(1, remaining.length()-2)
	var params := remaining.split("|")
	if params.size() == 1 && params[0] == "":
		pass
	else:
		for i in range(params.size()):
			params[i] = params[i].strip_edges()
		
		output.append_array(params)
	
	return output


class Variable:
	
	enum TYPES {BOOL, INT, STRING}
	
	var varName :String
	var data
	var dataType: int
	
	func _init(constructor: Array[String]) -> void:
		
		varName = constructor[0]
		
		match constructor[1]:
			"BOOL":
				dataType = TYPES.BOOL
			"INT":
				dataType = TYPES.INT
			"STRING":
				dataType = TYPES.STRING
		
		if constructor.size() > 2:
			match dataType:
				TYPES.BOOL:
					data = true if constructor[2].to_upper() == "TRUE" else false
				TYPES.INT:
					data = int(constructor[2])
				TYPES.STRING:
					data = constructor[2]
		else:
			match dataType:
				TYPES.BOOL:
					data = false
				TYPES.INT:
					data = 0
				TYPES.STRING:
					data = ""
	
	func _to_string() -> String:
		
		var formatString = "%s %s %s"
		
		var stringDataType : String = TYPES.find_key(dataType)
		
		return formatString % [varName, stringDataType, data]
class Token:
	enum TYPES {BOOL, INT, FLOAT, VAR, OPER}
	var type : int
	var data
