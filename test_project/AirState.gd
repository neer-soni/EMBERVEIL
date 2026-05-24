extends PlayerState

class_name AirState

@export var Landing_state : PlayerState 
@export var landing_animation : String = "landing"

func state_process(_delta):
	if(character.is_on_floor()):
		next_state = Landing_state

func on_exit():
	if(next_state == Landing_state):
		playback.travel(landing_animation)
