extends CharacterBody2D

@export var player_speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var speed_variation: float = 0.2
@export var jump_time_variation: float = 0.2

func _ready() -> void:
	# Apply a random variation to the player speed
	var variation = randf_range(-speed_variation, speed_variation)
	player_speed += player_speed * variation

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		await get_tree().create_timer(randf_range(0, jump_time_variation)).timeout
		if is_on_floor():
			velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)

	move_and_slide()

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
