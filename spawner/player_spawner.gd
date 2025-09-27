extends Marker2D
@export var spawn_timer: float = 2.0
@export var spawn_count: int = 25
@export var player_scene: PackedScene
@onready var game_manager: Node = get_tree().get_root().get_node("GameManager")

var players: Array[CharacterBody2D] = []

func _ready() -> void:
	GameManager.allow_restart = false
	for i in spawn_count:
		var player_instance = player_scene.instantiate()
		player_instance.global_position = global_position
		get_tree().get_first_node_in_group("game_root").call_deferred("add_child", player_instance)
		players.append(player_instance)
		await get_tree().create_timer(spawn_timer / spawn_count).timeout

	for i in players:
		i.enabled = true
	GameManager.allow_restart = true
	
	
