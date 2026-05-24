extends State1

class_name HitState

@export var Damageable              : damageable
@export var character_State_Machine : CharacterStateMachine
@export var _dead_state             : State1
@export var return_state            : State1  # set this to the walk/chase state
@export var hurt_animation          : String = "hurt"
@export var dead_animation_node     : String = "dead"
@export var knockback_speed         : float  = 400.0

@onready var timer : Timer = $Timer

# Remember what state we were in before getting hit so we can return to it
var _previous_state : State1 = null


func _ready() -> void:
	Damageable.connect("on_hit", on_Damageable_hit)


func on_enter() -> void:
	# Remember the state we came from (chase or walk) to return correctly
	_previous_state = character_State_Machine.current_state
	playback.travel(hurt_animation)
	timer.start()


func on_Damageable_hit(_node: Node, _damage_amount: int, _knockback_direction: Vector2) -> void:
	if Damageable.health > 0:
		character.velocity = knockback_speed * _knockback_direction
		emit_signal("interrupt_state", self)
	else:
		emit_signal("interrupt_state", _dead_state)
		playback.travel(dead_animation_node)


func on_exit() -> void:
	character.velocity = Vector2.ZERO


func _on_timer_timeout() -> void:
	# Return to whatever state the zombie was in before being hit
	# Falls back to return_state (walk) if nothing was recorded
	if _previous_state != null and _previous_state != self and _previous_state != _dead_state:
		next_state = _previous_state
	else:
		next_state = return_state
