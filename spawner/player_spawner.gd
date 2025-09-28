extends Marker2D
@export var spawn_timer: float = 2.0
@export var spawn_count: int = 25
@export var player_scene: PackedScene

@export var spawn_infinitely: bool = false

var players: Array[CharacterBody2D] = []

var timer: Timer

func _ready() -> void:
	if spawn_infinitely:
		timer = Timer.new()
		timer.wait_time = spawn_timer
		timer.one_shot = false
		timer.autostart = true
		add_child(timer)
		timer.timeout.connect(_on_timer_timeout)
		return
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

func _on_timer_timeout() -> void:
	var player_instance = player_scene.instantiate()
	player_instance.global_position = global_position
	get_tree().get_first_node_in_group("game_root").add_child(player_instance)
	players.append(player_instance)
