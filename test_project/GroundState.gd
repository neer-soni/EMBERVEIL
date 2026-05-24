extends PlayerState

class_name GroundState
@export var jump_velocity : float = -570.0
@export var air_state : PlayerState
@export var jump_animation : String = "jump"
@export var attack_state : PlayerState
@export var attack_node1 : String = "Attack_1"
@export var attack_node2 : String = "Attack_3"



func state_process(_delta):
	if(!character.is_on_floor()):
		next_state = air_state



func state_input(_event : InputEvent):
	if (_event.is_action_pressed("jump")):
		jump()
	if(_event.is_action_pressed("Attack1")):
		attack()
	if(_event.is_action_pressed("Attack3")):
		attack3()

func jump():
	character.velocity.y = jump_velocity 
	next_state = air_state
	playback.travel(jump_animation)

func attack():
	next_state = attack_state
	playback.travel(attack_node1)


func attack3():
	next_state = attack_state
	playback.travel(attack_node2)
