extends Marker2D
@export var spawn_timer: float = 2.0
@export var spawn_count: int = 25
@export var player_scene: PackedScene

var players: Array[CharacterBody2D] = []

func _ready() -> void:
	GameManager.allow_restart = false
	await get_tree().create_timer(0.5).timeout
	for i in range(spawn_count):
		print("Spawning player ", i)
		var player_instance = player_scene.instantiate()
		player_instance.global_position = global_position
		# Schedule add_child next frame; no await here
		get_tree().get_first_node_in_group("game_root").add_child.call_deferred(player_instance)
		players.append(player_instance)
		# Only wait between spawns
		if i < spawn_count - 1:
			await get_tree().create_timer(spawn_timer / max(1, spawn_count)).timeout

	for p in players:
		p.enabled = true
	GameManager.allow_restart = true
