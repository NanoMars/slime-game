extends Area2D

@export var signal_colour: Color = Color(1, 0, 0)

@onready var panel = $Sprite2D2/SubViewport/Panel
var _panel_style: StyleBoxFlat


var players_in_area: Array[Node]:
	get:
		return _players_in_area
	set(value):
		if value.size() >  _players_in_area.size() and _players_in_area.size() == 0:

			LogicManager.colour_enabled.emit(signal_colour)
			if _panel_style:
				_panel_style.border_color = Color(1.0, 1.0, 1.0)
		elif value.size() < _players_in_area.size() and value.size() == 0:

			LogicManager.colour_disabled.emit(signal_colour)
			if _panel_style:
				_panel_style.border_color = Color(0.0, 0.0, 0.0)
		_players_in_area = value
		print("Players in aasdfrea: ", _players_in_area.size())

var _players_in_area: Array[Node] = []

var enabled: bool:
	get:
		return players_in_area.size() > 0
	set(value):
		pass

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	

	# Prepare a mutable stylebox override and set initial background color
	var base_style: StyleBox = panel.get_theme_stylebox("panel")
	if base_style:
		_panel_style = base_style.duplicate()
	else:
		_panel_style = StyleBoxFlat.new()
	panel.add_theme_stylebox_override("panel", _panel_style)
	_panel_style.bg_color = signal_colour

func _body_entered(body: Node) -> void:
	print("Body entered: ", body)
	if body is CharacterBody2D:
		var temp_array = players_in_area.duplicate()
		temp_array.append(body)
		players_in_area = temp_array
		print("Players in area: ", players_in_area.size())

func _body_exited(body: Node) -> void:
	print("Body exited: ", body)
	if body is CharacterBody2D and body.is_in_group("player"):
		var temp_array = players_in_area.duplicate()
		temp_array.erase(body)
		players_in_area = temp_array
		print("Players in area: ", players_in_area.size())
