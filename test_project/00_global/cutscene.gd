extends Node2D

@onready var video_player: VideoStreamPlayer = $CanvasLayer/Control/VideoStreamPlayer
@onready var skip_label: Label = $CanvasLayer/Control/Label

# Path to your first map scene
const FIRST_MAP_UID = "uid://d2btqn8sfli11"

func _ready():
	skip_label.text = "Press SPACE or ENTER to skip"
	
	# Connect the finished signal
	video_player.finished.connect(_on_video_finished)
	
	# Play the video
	video_player.play()

func _input(event):
	# Allow skipping with Space, Enter, or mouse click
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		_go_to_first_map()
	
	if event is InputEventMouseButton and event.pressed:
		_go_to_first_map()

func _on_video_finished():
	_go_to_first_map()

func _go_to_first_map():
	SceneManager.transition_scene(FIRST_MAP_UID, "LevelTransition", Vector2.ZERO, "left")
