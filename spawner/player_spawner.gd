extends Marker2D
@export var spawn_timer: float = 2.0
@export var spawn_count: int = 25
@export var player_scene: PackedScene

func _ready() -> void:
	for i in spawn_count:
		var player_instance = player_scene.instantiate()
		player_instance.global_position = global_position
		get_tree().get_first_node_in_group("game_root").add_child(player_instance)
		await get_tree().create_timer(spawn_timer / spawn_count).timeout
