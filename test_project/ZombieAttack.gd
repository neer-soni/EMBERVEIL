extends State1

class_name ZombieAttackState

@export var chase_state      : State1
@export var attack_range     : float  = 80.0
@export var return_anim_node : String = "run"
@export var hitbox           : Area2D

# All 3 attack animation names
@export var attack_anim_1    : String = "Attack1"
@export var attack_anim_2    : String = "Attack2"
@export var attack_anim_3    : String = "Attack3"

var player : CharacterBody2D = null
var _current_attack : String = ""


func on_enter() -> void:
	character.velocity.x = 0.0
	# Pick a random attack each time
	var attacks = [attack_anim_1, attack_anim_2, attack_anim_3]
	_current_attack = attacks[randi() % attacks.size()]
	if playback:
		playback.travel(_current_attack)


func state_process(_delta: float) -> void:
	pass


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == _current_attack:
		if hitbox:
			hitbox.monitoring = false
		next_state = chase_state
		if playback:
			playback.travel(return_anim_node)


func on_exit() -> void:
	character.velocity = Vector2.ZERO
	if hitbox:
		hitbox.monitoring = false
