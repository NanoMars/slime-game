extends Node
@export var level_number: int = 1
@export var level_name: String = "Introduction"
@export var game_manager_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.setup_game(self, level_number, level_name, game_manager_enabled)
