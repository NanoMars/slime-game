extends CanvasLayer

@export var level_label: Label
@export var name_label: Label

var level_name: String:
	get:
		return _level_name
	set(value):
		_level_name = value
		name_label.text = str(_level_name)
var _level_name: String = ""

var level_number: int:
	get:
		return _level_number
	set(value):
		_level_number = value
		level_label.text = "Level " + str(_level_number)

var _level_number: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
