@tool
class_name Level_transition extends Node2D

enum SIDE { LEFT , RIGHT , TOP , BOTTOM }
const LEVEL_MUSIC = {
	"uid://d2btqn8sfli11": "level1",
	"uid://ctnakk24novkh": "level2",
	"uid://bea3qs0f5uqff": "level3",
	"uid://df8u05p7a7t57": "final",
}
@export_range(2 , 16, 1, "or_greater ") var size : int = 2 : 
	set (value):
		size = value 
		apply_area_settings()
@export var location : SIDE = SIDE.LEFT:
	set(value):
		location = value
		apply_area_settings()

@export_file("*.tscn") var target_level : String = ""
@export var target_area_name : String = "LevelTransition"

@onready var area_2d : Area2D = $Area2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return 
	SceneManager.new_scene_ready.connect(_on_new_scene_ready)
	SceneManager.load_scene_finished.connect(_on_load_scene_finished)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if SceneManager.new_scene_ready.is_connected(_on_new_scene_ready):
		SceneManager.new_scene_ready.disconnect(_on_new_scene_ready)
	if SceneManager.load_scene_finished.is_connected(_on_load_scene_finished):
		SceneManager.load_scene_finished.disconnect(_on_load_scene_finished)



func _on_new_scene_ready(target_name : String, offset : Vector2):
	if target_name == name:
		var player : Node = get_tree().get_first_node_in_group("player")
		player.global_position = global_position + offset

func _on_load_scene_finished():
	if not area_2d.body_entered.is_connected(_on_player_entered):
		area_2d.body_entered.connect(_on_player_entered)

func get_offset(_player : Node2D) -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		if location == SIDE.LEFT:
			offset.x = -12
		else:
			offset.x = 12
	else:
		if location == SIDE.TOP:
			offset.x = -2
		else:
			offset.x = 2

	return offset

func apply_area_settings() -> void:
	area_2d = get_node_or_null("Area2D") 
	if not area_2d:
		return 
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		area_2d.scale.y = size
		if location == SIDE.LEFT: 
			area_2d.scale.x = -1
		else:
			area_2d.scale.x = 1
	else:
		area_2d.scale.x = size
		if location == SIDE.TOP:
			area_2d.scale.y = 1
		else:
			area_2d.scale.y = -1
func _on_player_entered(_n: Node2D) -> void:
	AudioManager.play_sfx("level_transition")

	var next_level_number = SaveManager.get_level_number(target_level)
	if next_level_number > SaveManager.save_data["last_unlocked_level"]:
		SaveManager.save_data["last_unlocked_level"] = next_level_number
		SaveManager.save()
	
	SceneManager.transition_scene(target_level, target_area_name, get_offset(_n), "left")
