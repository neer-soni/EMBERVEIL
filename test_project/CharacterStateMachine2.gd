extends Node
class_name CharacterStateMachine2 

@export var character : CharacterBody2D 
@export var current_state : State2
@export var animation_tree : AnimationTree
var States : Array[State2]

func _ready():
	for child in get_children():
		if child is State2:
			States.append(child)
			
			child.character = character
			child.playback = animation_tree["parameters/playback"] 
			
			child.connect("interrupt_state", on_state_interrupt_state)
			
			
		else:
			push_warning("Child " + child.name + " is not a CharacterStateMachine child")
	
	# Initialize current_state if not set in Inspector
	if current_state == null:
		if States.size() > 0:
			current_state = States[0]
		else:
			push_error("CharacterStateMachine has no State children!")

func _physics_process(_delta):
	if(current_state.next_state != null):
		switch_states(current_state.next_state)
		
	current_state.state_process(_delta)
		



func check_if_can_move() -> bool:
	if current_state == null:
		push_error("current_state is null in CharacterStateMachine!")
		return false
	return current_state.can_move

func switch_states(new_state : State2):
	if(current_state  != null):
		current_state.on_exit()
		current_state.next_state = null
		
		
	current_state = new_state
	
	current_state.on_enter()

func _input(_event: InputEvent):
	current_state.state_input(_event)

func on_state_interrupt_state(new_state : State2 ):
	switch_states(new_state)
