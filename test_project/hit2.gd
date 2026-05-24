extends State
class_name HitState2

@export var damageable_component    : Damageable
@export var character_State_Machine : StateMachine
@export var _dead_state             : State
@export var return_state            : State

@export var hurt_animation          : String = "hurt"
@export var dead_animation_node     : String = "dead"
@export var knockback_speed         : float  = 400.0

@onready var timer : Timer = $Timer

var _previous_state : State = null


func _ready() -> void:
	damageable_component.connect("on_hit", on_Damageable_hit)


func on_enter() -> void:
	_previous_state = character_State_Machine.get_current_state()
	playback.travel(hurt_animation)
	timer.start()


func on_Damageable_hit(_node: Node, _damage_amount: int, _knockback_direction: Vector2) -> void:
	if damageable_component.get_health() > 0:
		character.velocity = knockback_speed * _knockback_direction
		emit_signal("interrupt_state", self)
	else:
		emit_signal("interrupt_state", _dead_state)
		playback.travel(dead_animation_node)


func on_exit() -> void:
	character.velocity = Vector2.ZERO


func _on_timer_timeout() -> void:
	if _previous_state != null and _previous_state != self and _previous_state != _dead_state:
		next_state = _previous_state
	else:
		next_state = return_state
