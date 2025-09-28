extends Node

var music: AudioStream

var started: bool = false
# Called when the node enters the scene tree for the first time.
func _play_music(music_set: AudioStream) -> void:
	if started:
		return
	started = true
	music = music_set
	var player = AudioStreamPlayer.new()
	player.stream = music
	player.autoplay = true
	player.bus = "Music"
	add_child(player)
	player.play()
	
func play_death_sound() -> void:
	var death_sound = AudioStreamPlayer.new()
	death_sound.stream = load("res://assets/audio/error_006.ogg")
	death_sound.bus = "SFX"
	add_child(death_sound)
	death_sound.play()
	await death_sound.finished
	death_sound.queue_free()