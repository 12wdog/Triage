extends Node
class_name Dialogue

signal cont()
signal blackout_done()

var var_color := "06402b"

var dialogue : PackedStringArray

var manager : Manager

var functions: Dictionary
var variables: Dictionary
var characters: Dictionary
var backgrounds: Dictionary
var sounds: Dictionary
var musics: Dictionary
var jumppoints: Dictionary

var can_continue := true
var blacked_out := false

@onready var speaker : Label = $HeadContainer/PanelContainer/MarginContainer2/VBoxContainer/MarginContainer/NamePanel/Name
@onready var speaker_panel : PanelContainer = $HeadContainer/PanelContainer/MarginContainer2/VBoxContainer/MarginContainer/NamePanel
@onready var words : RichTextLabel = $HeadContainer/PanelContainer/MarginContainer2/VBoxContainer/PanelContainer2/Dialogue
@onready var words_panel : PanelContainer = $HeadContainer/PanelContainer/MarginContainer2/VBoxContainer/PanelContainer2

func read_file(path : String) -> void:
	
	functions.clear()
	variables.clear()
	backgrounds.clear()
	sounds.clear()
	musics.clear()
	jumppoints.clear()
	
	dialogue = FileOpener.getFile(path)
	
	_get_functions()
	
	if functions.has("#VARS"):
		_get_vars()
	if functions.has("#CHARS"):
		_get_chars()
	if functions.has("#SOUNDS"):
		_get_sounds()

func read_next_line() -> void:
	if can_continue:
		cont.emit();

func start() -> void:
	self.visible = true
	await _read(functions.get("#MAIN") + 1)
	self.visible = false

func _read(line : int) -> int:
	while(true):
		var current_line :String = dialogue[line]
		if current_line == "[END]":
			return line
		elif current_line[0] == '#':
			_set_name(current_line.trim_prefix("#"))
			line += 1
		elif current_line[0] == '{':
			await _run_command(line)
			line += 1
		else:
			_write(current_line)
			line += 1
			await cont
	
	return 0;

func _run_command(pos: int) -> void:
	var line := dialogue[pos]
	var command := _split_command(line)

	match command[0]:
		"BLACKOUT":
			blacked_out = !blacked_out
			can_continue = false
			#await blackout_done
			can_continue = true
		"BLANK":
			_write("")
			await cont
		"INSTABLANK":
			_write("")
		"NONE":
			speaker_panel.visible = false
		"FUNC":
			assert(functions.has(command[1]))
			await _read(functions.get(command[1]) + 1)
		"IF":
			if command.size() == 3:
				if _bool_from_strings(command[1]):
					await _read(functions.get(command[2]) + 1)
			else:
				if _bool_from_strings(command[1]):
					await _read(functions.get(command[2]) + 1)
				else:
					await _read(functions.get(command[3]) + 1)
		"WAIT":
			await get_tree().create_timer(float(command[1])).timeout
		"HIDE":
			words_panel.visible = false
		"SHOW":
			words_panel.visible = true
		"CALL":
			_run_intern_function(command[1], command.slice(2))
		_:
			_write(line)
			await cont

func _run_intern_function(function : String, args : Array[String]) -> void:
	var function_call = Callable.create(manager, function)
	function_call.call(args)

func _write(line: String) -> void:
	if line.contains('('):
		var charPosition = line.find('(')
		
		while charPosition < line.length():
			var varName : String = line[charPosition]
			while line[charPosition] != ')':
				charPosition += 1
				varName += line[charPosition]
			
			line = line.replace(varName, '[color=' + var_color + ']' + str(variables.get(varName.substr(1, varName.length() - 2)).data) + '[/color]')
			
			if line.contains('('):
				charPosition = line.find('(')
			else:
				break
	
	words.text = '[center]' + line

func _set_name(new_name : String) -> void:
	speaker.text = new_name.capitalize()
	speaker_panel.visible = true

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

func _bool_from_strings(string: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\S+")
	var tokens := string.split(' ')
	var readTokens : Array[Token] = []
	for token in tokens:
		var currentToken := Token.new()
		if token.is_valid_float():
			if token.is_valid_int():
				currentToken.type = currentToken.TYPES.INT
				currentToken.data = int(token)
			else:
				currentToken.type = currentToken.TYPES.FLOAT
				currentToken.data = float(token)
		elif token == "TRUE":
			currentToken.type = currentToken.TYPES.BOOL
			currentToken.data = true
		elif token == "FALSE":
			currentToken.type = currentToken.TYPES.BOOL
			currentToken.data = false
		elif token == "==":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == "<":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == ">":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == "<=":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == ">=":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == "!":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token
		elif token == "!=":
			currentToken.type = currentToken.TYPES.OPER
			currentToken.data = token

		else:
			currentToken.type = currentToken.TYPES.VAR
			currentToken.data = variables.get(token)
		
		readTokens.append(currentToken)

	return _bool_from_tokens(readTokens)

func _bool_from_tokens(tokens : Array[Token]) -> bool:
	
	if tokens.size() == 1:
		
		if tokens[0].type == Token.TYPES.VAR:
			return bool(tokens[0].data.data)
		else:
			return bool(tokens[0].data)
	if tokens.size() == 2:
		assert(tokens[0].data == "!")
		
		if tokens[1].type == Token.TYPES.VAR:
			return !bool(tokens[1].data.data)
		else:
			return !bool(tokens[1].data)
	if tokens.size() == 3:
		
		var var1
		var var2
		
		if tokens[0].type == Token.TYPES.VAR:
			var1 = tokens[0].data.data
		else:
			var1 = tokens[0].data
		
		if tokens[2].type == Token.TYPES.VAR:
			var2 = tokens[2].data.data
		else:
			var2 = tokens[2].data
		
		match tokens[1].data:
			"==":
				return var1 == var2
			"<":
				return var1 < var2
			">":
				return var1 > var2
			"<=":
				return var1 <= var2
			">=":
				return var1 >= var2
	return false


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
