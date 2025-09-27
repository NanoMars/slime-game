extends Node2D
@onready var area_2d: Area2D = $Area2D
@onready var count_label: Label = $Sprite2D2/SubViewport/Label
@export var required_players: int = 5
@export_file("*.tscn") var next_level_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count_label.text = str(required_players)
	area_2d.body_entered.connect(_on_body_entered)
	$DoorEnteredSound.max_polyphony = required_players
	add_to_group("door")

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		required_players = max(required_players - 1, 0)
		count_label.text = str(required_players)
		body.queue_free()
		$DoorEnteredSound.play()
		if required_players <= 0:
			$DoorUnlockedSound.play()
			if next_level_scene == "":
				print("No next level scene set!")
				return
			SceneManager.change_scene(next_level_scene)
			
