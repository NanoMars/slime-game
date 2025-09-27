extends CharacterBody2D

@export var player_speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var speed_variation: float = 0.2
@export var jump_time_variation: float = 0.2

var touch_ground_last_tick: bool = false
var airtime: float = 0.0
@export var airtime_minimum_sound: float = 0.2

var players_above: Array[CharacterBody2D] = []
var players_below: Array[CharacterBody2D] = []

func _ready() -> void:
	# Apply a random variation to the player speed
	var variation = randf_range(-speed_variation, speed_variation)
	player_speed += player_speed * variation
	add_to_group("player")



func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not touch_ground_last_tick and is_on_floor() and airtime > 0.0:
		if airtime > airtime_minimum_sound:
			print("Play landing sound")
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
	if Input.is_action_pressed("jump") and is_on_floor() and players_above.is_empty(): # was: not players_above
		jump(randf_range(0, jump_time_variation))
		if not players_below.is_empty():			
			for p in players_below:
				if is_instance_valid(p):
					p.jump(0.1)

	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)

	move_and_slide()

	# Print ShapeCast2D collisions
	if $ShapeCast2D.is_colliding() and is_on_floor():
		print("ShapeCast2D collision count: ", $ShapeCast2D.get_collision_count())
		players_below.clear() # rebuild fresh each frame we detect collisions on floor
		for i in range($ShapeCast2D.get_collision_count()):
			var collider = $ShapeCast2D.get_collider(i)
			if collider and collider is CharacterBody2D and collider != self and collider.is_in_group("player"):
				if global_position.y < collider.global_position.y:
					if not players_below.has(collider):
						players_below.append(collider) # was: players_below = collider
					if not collider.players_above.has(self):
						collider.players_above.append(self) # was: collider.players_above = self
	

	if get_tile_kill():
		queue_free()

func get_tile_kill() -> bool:
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")

	if not tilemap:
		return false

	var cell := tilemap.local_to_map(global_position)
	var data: TileData = tilemap.get_cell_tile_data(cell)

	if data:
		var kill: bool = data.get_custom_data("kill")
		if kill:
			return kill

	return false

func jump(delay: float = 0) -> void:
	await get_tree().create_timer(delay).timeout
	if is_on_floor():
		velocity.y = jump_velocity
		$JumpAudio.play()
