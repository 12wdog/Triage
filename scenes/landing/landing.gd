extends Node2D
class_name Landing

signal zone_click(item_name : String)

@onready var cabinet : Area2D = $Selections/Cabinet
@onready var bed1 : Area2D = $Selections/Bed1
@onready var bed2 : Area2D = $Selections/Bed2
@onready var bed3 : Area2D = $Selections/Bed3

func _ready():
	for item in [cabinet, bed1, bed2, bed3]:
		item.input_event.connect(func(_viewport, event, _shape_idx): input_event(item, event))

func input_event(item : Area2D, event : InputEvent):
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.pressed \
	and not event.double_click:
		zone_click.emit(item.name)
