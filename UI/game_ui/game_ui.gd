extends CanvasLayer

@export var level_label: Label
@export var name_label: Label
@export var player_count_label: Label

var player_count: int:
	get:
		return 1
	set(value):
		player_count_label.text = str(value)

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
