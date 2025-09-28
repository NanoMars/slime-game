extends Node


var allow_restart: bool = false

var ui_path: String = "res://UI/game_ui/game_ui.tscn"
var world_boundary_path: String = "res://game/world_boundary.tscn"
var enabled: bool = true
var ui_instance: Node = null
	
func setup_game(game_root: Node, level_number: int, level_name: String, gm_enabled: bool) -> void:
	enabled = gm_enabled
	if not enabled:
		return
	var ui_scene: PackedScene = load(ui_path)
	ui_instance = ui_scene.instantiate()
	ui_instance.level_number = level_number
	ui_instance.level_name = level_name
	game_root.add_child(ui_instance)
	
	var world_boundary_scene: PackedScene = load(world_boundary_path)
	var world_boundary_instance = world_boundary_scene.instantiate()
	game_root.add_child(world_boundary_instance)
	

func get_player_count() -> int:
	if not enabled:
		return 0

	var valid_players: int = 0
	for i in get_tree().get_nodes_in_group("player"):
		if i is CharacterBody2D:
			if is_instance_valid(i) and i.is_stuck == false:
				valid_players += 1
	return valid_players

func get_min_players() -> int:
	if not enabled:
		return 0
	var door = get_tree().get_first_node_in_group("door")
	var min_players: int = 1
	if door:
		min_players = door.required_players
	return min_players

func player_count_changed() -> void:
	print("Player count changed to ", get_player_count())
	if not enabled:
		return
	await get_tree().process_frame

	ui_instance.player_count = get_player_count()

	if get_player_count() < get_min_players() and allow_restart:
		SceneManager.reload_scene()
		MusicManager.play_death_sound()
	
