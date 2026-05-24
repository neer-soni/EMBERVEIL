extends Node

class_name PlayerState

@export var can_move : bool = true 


var character : CharacterBody2D
var next_state : PlayerState
var playback : AnimationNodeStateMachinePlayback 


@warning_ignore("unused_signal")
signal interrupt_state(new_state : PlayerState)




func state_process(_delta):
	pass

func state_input(_event : InputEvent):
	pass

func on_enter():
	pass
	
func on_exit():
	pass
