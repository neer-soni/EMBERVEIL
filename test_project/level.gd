extends Node2D

@export var music_key : String = "level1"

func _ready():
	AudioManager.play_music(music_key)
