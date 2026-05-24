extends State2

class_name ZombieChaseState2

@export var walk_state      : State2
@export var attack_state    : State2 
@export var chase_speed     : float  = 120.0
@export var attack_range    : float  = 100.0
@export var sight_range     : float  = 1500.0
@export var chase_anim_node : String = "run"

var player : CharacterBody2D = null


func on_enter() -> void:
	if playback:
		playback.travel(chase_anim_node)


func state_process(_delta: float) -> void:
	if player == null or character == null:
		next_state = walk_state
		return

	var player_center  : Vector2 = _get_center(player)
	var zombie_center  : Vector2 = _get_center(character)
	var to_player      : Vector2 = player_center - zombie_center
	var dist           : float   = to_player.length()

	if dist > sight_range:
		next_state = walk_state
		return

	if dist <= attack_range:
		next_state = attack_state
		return

	# Move toward player center
	character.velocity.x = sign(to_player.x) * chase_speed


func _get_center(body: CharacterBody2D) -> Vector2:
	var col := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		return col.global_position
	return body.global_position
