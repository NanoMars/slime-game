extends Area2D

@export var signal_colour: Color = Color(1, 0, 0)

@onready var panel = $Panel
var _panel_style: StyleBoxFlat

@onready var button_press_sound = $ButtonPressSound
@onready var button_release_sound = $ButtonReleaseSound

var players_in_area: Array[Node]:
	get:
		return _players_in_area
	set(value):
		if value.size() != _players_in_area.size():
			if value.size() > 0 and _players_in_area.size() == 0:

				LogicManager.colour_enabled.emit(signal_colour)
				button_press_sound.play()
				if _panel_style:
					_panel_style.border_color = Color(1.0, 1.0, 1.0)
			elif value.size() == 0 and _players_in_area.size() > 0:

				LogicManager.colour_disabled.emit(signal_colour)
				button_release_sound.play()
				if _panel_style:
					_panel_style.border_color = Color(0.0, 0.0, 0.0)

		_players_in_area = value

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
	if body is CharacterBody2D and body.is_in_group("player"):
		players_in_area.append(body)

func _body_exited(body: Node) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		players_in_area.erase(body)
