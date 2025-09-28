extends CharacterBody2D

@export var player_speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var speed_variation: float = 0.2
@export var jump_time_variation: float = 0.2
@export var jump_coyote_time: float = 0.1
@export_flags_2d_physics var enabled_collision_layers
@export_flags_2d_physics var disabled_collision_layers

@onready var sprite: Sprite2D = $Sprite2D

var direction := 0.0
var prev_direction := 0.0
var touch_ground_last_tick: bool = false
var airtime: float = 0.0
@export var airtime_minimum_sound: float = 0.2

@onready var anim_player = $AnimationPlayer

@export var enabled: bool = true

var players_above: Array[CharacterBody2D] = []
var players_below: Array[CharacterBody2D] = []

var is_stuck: bool = false

var raycast_grounded: bool = false

func _ready() -> void:
	# Apply a random variation to the player speed
	var variation = randf_range(-speed_variation, speed_variation)
	$Sprite2D.frame_coords.y = randi_range(0, 4)
	player_speed += player_speed * variation
	add_to_group("player")
	GameManager.player_count_changed()
func _physics_process(delta: float) -> void:

	if is_stuck:
		return

	if $ShapeCast2D.is_colliding() and is_on_floor():
		players_below.clear() # rebuild fresh each frame we detect collisions on floor
		for i in range($ShapeCast2D.get_collision_count()):
			var collider = $ShapeCast2D.get_collider(i)
			if collider and collider is TileMapLayer and collider != self and !collider.is_in_group("player"):
				for t in get_tile_data():
					if t == "sticky" and get_tile_data()[t] == false or !t.contains("sticky") and get_tile_data()[t] == false:
						raycast_grounded = true
			elif collider and collider is CharacterBody2D and collider != self and collider.is_in_group("player"):
				if global_position.y < collider.global_position.y:
					if not players_below.has(collider):
						players_below.append(collider) # was: players_below = collider
					if not collider.players_above.has(self):
						collider.players_above.append(self) # was: collider.players_above = self
					raycast_grounded = false

	# Add the gravity.
	if not touch_ground_last_tick and is_on_floor() and airtime > 0.0:
		if airtime > airtime_minimum_sound:
			$LandAudio.play()
		

		airtime = 0.0
	
	touch_ground_last_tick = is_on_floor()
	if not is_on_floor():
		velocity += get_gravity() * delta
		airtime += delta
		players_below.clear() # was: players_below = null

	if not is_on_ceiling():
		players_above.clear() # was: players_above = null
		

	# Handle jump.
	if Input.is_action_pressed("jump") and (is_on_floor() or airtime <= jump_coyote_time) and players_above.is_empty(): # was: not players_above
		jump(randf_range(0, jump_time_variation))
		if not players_below.is_empty():			
			for p in players_below:
				if is_instance_valid(p):
					p.jump(0.1)

	
	direction = Input.get_axis("move_left", "move_right")
	if direction and enabled:
		velocity.x = direction * player_speed
		if direction > 0.0:
			anim_player.play("run_right")
		else:
			anim_player.play("run_left")
		prev_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		if prev_direction > 0.0:
			anim_player.play("idle_right")
		else:
			anim_player.play("idle_left")

	move_and_slide()

	
	

	if get_tile_data():
		print("Tile data: ", get_tile_data())
		if get_tile_data().has("kill") and get_tile_data()["kill"] == true:
			die()
		if get_tile_data().has("sticky") and get_tile_data()["sticky"] and is_on_floor() and players_below.is_empty() and raycast_grounded:
			await get_tree().process_frame
			if is_on_floor() and players_below.is_empty():
				stick()


func get_tile_data() -> Dictionary[String, Variant]:
	var result: Dictionary[String, Variant] = {}

	# Collect every TileMap/TileMapLayer in the "tilemap" group.
	var nodes := get_tree().get_nodes_in_group("tilemap")
	if nodes.is_empty():
		return result

	for n in nodes:
		var tilemap: Node = n
		if not (tilemap is TileMapLayer or tilemap is TileMap):
			continue

		# Use the tilemap's local coords when mapping to cells.
		var local_pos: Vector2 = tilemap.to_local(global_position)
		var cell: Vector2i = tilemap.local_to_map(local_pos)
		var data: TileData = tilemap.get_cell_tile_data(cell)
		if data == null:
			continue

		var tileset: TileSet = tilemap.tile_set
		if tileset == null:
			continue

		for i in range(tileset.get_custom_data_layers_count()):
			var layer_name: String = tileset.get_custom_data_layer_name(i)
			var custom_data: Variant = data.get_custom_data(layer_name)
			if custom_data == null:
				continue

			if result.has(layer_name):
				var existing: Variant = result[layer_name]
				# If both are bools, OR them so any true wins; otherwise last-wins.
				if typeof(existing) == TYPE_BOOL and typeof(custom_data) == TYPE_BOOL:
					result[layer_name] = existing or custom_data
				else:
					result[layer_name] = custom_data
			else:
				result[layer_name] = custom_data

	return result

func die() -> void:
	var particles = $CPUParticles2D
	var DeathAudio = $DeathAudio
	remove_child(DeathAudio)
	get_parent().add_child(DeathAudio)
	DeathAudio.play()
	
	remove_child(particles)
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true
	GameManager.player_count_changed()
	queue_free()

func stick() -> void:
	is_stuck = true
	sprite.modulate = Color(1.0, 0.761, 0.494)
	$StuckSound.play()
	GameManager.player_count_changed()

func jump(delay: float = 0) -> void:
	await get_tree().create_timer(delay).timeout
	if is_on_floor() and check_player_below_grounded() and enabled:
		if prev_direction > 0.0:
			anim_player.play("jump_right")
		else:
			anim_player.play("jump_left")
		velocity.y = jump_velocity
		$JumpAudio.play()

func check_player_below_grounded() -> bool:
	if players_below.is_empty():
		return true
	
	for p in players_below:
		if is_instance_valid(p) and not p.is_on_floor():
			return false

	return true
