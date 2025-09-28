extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	SceneManager.change_scene("res://game/levels/level_1.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
