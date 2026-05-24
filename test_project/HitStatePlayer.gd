extends PlayerState
class_name HitStatePlayer

@export var damageable_component    : Damageable
@export var character_State_Machine : PlayerCharacterStateMachine
@export var _dead_state             : PlayerState
@export var return_state            : PlayerState
@export var hurt_animation          : String = "Hurt"
@export var dead_animation_node     : String = "Dead"
@export var knockback_speed         : float  = 500.0

@onready var timer : Timer = $Timer

var _knockback_dir : Vector2 = Vector2.ZERO

func _ready() -> void:
	damageable_component.connect("on_hit", on_Damageable_hit)

func on_enter() -> void:
	character.velocity = knockback_speed * Vector2(_knockback_dir.x, -0.5)
	playback.travel("move")
	playback.travel(hurt_animation)
	timer.start()

func on_Damageable_hit(_node: Node, _damage_amount: int, _knockback_direction: Vector2) -> void:
	# Guard 1 — already dead, ignore everything
	if character_State_Machine.current_state == _dead_state:
		return

	print("Hit! Health: ", damageable_component.get_health())

	# Guard 2 — just died, switch to dead state
	if damageable_component.get_health() <= 0:
		print("Health <= 0, switching to dead state: ", _dead_state)
		emit_signal("interrupt_state", _dead_state)
		return

	# Normal hit processing
	_knockback_dir = _knockback_direction
	if character_State_Machine.current_state != self:
		emit_signal("interrupt_state", self)
	else:
		character.velocity = knockback_speed * Vector2(_knockback_direction.x, -0.5)
		playback.travel("move")
		playback.travel(hurt_animation)
		timer.start()

func on_exit() -> void:
	pass

func _on_timer_timeout() -> void:
	next_state = return_state
