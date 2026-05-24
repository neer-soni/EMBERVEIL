extends PlayerState
@export var return_state : PlayerState
@export var return_animation_node : String = "move"
@export var Attack_1_name : String = "Attack_1"
@export var Attack_2_name : String = "Attack_2"
@export var Attack_3_name : String = "Attack_3"
@export var Attack_2_node : String = "Attack_2"

@onready var timer : Timer = $Timer




func state_input(_event : InputEvent):
	if(_event.is_action_pressed("Attack2")):
		timer.start()



func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == Attack_1_name):
		if(timer.is_stopped()):
			next_state = return_state
			playback.travel(return_animation_node)
			
		else:
			playback.travel(Attack_2_node)
		
	if(anim_name == Attack_2_name):
		next_state = return_state
		playback.travel(return_animation_node)
		
		
	if(anim_name == Attack_3_name):
		next_state = return_state
		playback.travel(return_animation_node)
		
		
