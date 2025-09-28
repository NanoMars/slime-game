extends StaticBody2D
class_name Gate
@export var listen_colour: Color = Color(1, 0, 0)

@onready var gate_open_sound = $GateOpenSound
@onready var gate_close_sound = $GateCloseSound
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var highlight_sprite: Sprite2D = $HighlightSprite
@onready var anim_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LogicManager.colour_enabled.connect(_on_colour_enabled)
	LogicManager.colour_disabled.connect(_on_colour_disabled)
	highlight_sprite.modulate = listen_colour

func _on_colour_enabled(colour: Color) -> void:
	print("Colour enabled: ", colour, " listening for: ", listen_colour)
	if colour == listen_colour:
		gate_open_sound.play()
		anim_player.play("open")
		await anim_player.animation_finished
		collision_shape.set_deferred("disabled", true)
		

func _on_colour_disabled(colour: Color) -> void:
	print("Colour disabled: ", colour, " listening for: ", listen_colour)
	if colour == listen_colour:
		gate_close_sound.play()
		
		anim_player.play("close")
		await anim_player.animation_finished
		collision_shape.set_deferred("disabled", false)
