extends Node

var music: AudioStream
# Called when the node enters the scene tree for the first time.
func _play_music(music_set: AudioStream) -> void:
	music = music_set
	var player = AudioStreamPlayer.new()
	player.stream = music
	player.autoplay = true
	player.bus = "Music"
	add_child(player)
	player.play()
	
