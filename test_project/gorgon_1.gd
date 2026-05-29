extends CharacterBody2D

@onready var animation_tree  : AnimationTree    = $AnimationTree
@onready var state_machine   : StateMachine     = $StateMachine
@onready var sprite          : Sprite2D         = $Sprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var damageable      : Damageable       = $Damageable
@onready var dead_state      : State            = $StateMachine/dead

@export var hit_state    : State
@export var walk_state   : State
@export var chase_state  : ZombieChaseState
@export var attack_state : ZombieAttackState

@export var starting_moving_direction : Vector2 = Vector2.LEFT
@export var movement_speed            : float   = 30.0
@export var detection_range           : float   = 1200.0

@export var sprite_pos_facing_left  : float = 834.0
@export var sprite_pos_facing_right : float = 834.0

## Path to your victory scene
@export var victory_scene_path   : String = "uid://gwh4clyy6v58"
## Slide direction for SceneManager transition  (left / right / up / down)
@export var transition_direction : String = "down"
## Seconds to wait after health = 0 before transitioning — match your death anim length
@export var death_to_victory_delay : float = 2.0

var gravity   : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _player   : CharacterBody2D = null
var _is_dying : bool  = false

signal facing_direction_changed(facing_right: bool)


func _ready() -> void:
	animation_tree.active = true
	await get_tree().process_frame

	_player = _find_player(get_tree().root)

	var playback : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

	if chase_state:
		chase_state.set_character(self)
		chase_state.set_playback(playback)
		chase_state.set_player(_player)

	if attack_state:
		attack_state.set_character(self)
		attack_state.set_playback(playback)
		attack_state.set_player(_player)
		animation_tree.connect("animation_finished", attack_state.on_animation_finished)

	damageable.on_hit.connect(_on_boss_hit)


func _find_player(node: Node) -> CharacterBody2D:
	if node is Player:
		return node
	for child in node.get_children():
		var result := _find_player(child)
		if result:
			return result
	return null


func get_player_center() -> Vector2:
	if _player == null:
		return Vector2.ZERO
	var col := _player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		return col.global_position
	return _player.global_position


func get_zombie_center() -> Vector2:
	if collision_shape:
		return collision_shape.global_position
	return global_position


func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var current : State = state_machine.get_current_state()

	if current == chase_state or current == attack_state:
		update_facing()
		move_and_slide()
		return

	if not state_machine.check_if_can_move():
		move_and_slide()
		return

	if _player != null:
		var dist := (get_player_center() - get_zombie_center()).length()
		if dist <= detection_range:
			state_machine.switch_states(chase_state)
			update_facing()
			move_and_slide()
			return

	velocity.x = starting_moving_direction.x * movement_speed
	update_facing_direction(velocity.x)
	move_and_slide()


func _on_boss_hit(_node: Node, _damage: int, _knockback: Vector2) -> void:
	if _is_dying:
		return
	if damageable.health <= 0.0:
		_begin_death()


func _begin_death() -> void:
	_is_dying = true
	velocity   = Vector2.ZERO

	if dead_state:
		state_machine.switch_states(dead_state)

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	# ── Audio: fade out level music via AudioManager ─────────────────────────
	# stop_music(true) tweens music_player.volume_db → -80 over 0.5 s,
	# then calls music_player.stop(). AudioManager handles everything internally.
	
	

	# ── Transition: capture refs NOW before queue_free() kills this node ─────
	# The C++ Damageable calls queue_free() on us when the death anim ends.
	# Any `await` on this node would be cancelled at that point, so we store
	# references into a SceneTree-level timer lambda that outlives this node.
	var tree      := get_tree()
	var scene_mgr := get_node_or_null("/root/SceneManager")

	tree.create_timer(death_to_victory_delay, false).timeout.connect(
		func() -> void:
			if scene_mgr and is_instance_valid(scene_mgr):
				scene_mgr.transition_scene(
					victory_scene_path,
					"",           # no target area in victory screen
					Vector2.ZERO, # no player to reposition
					transition_direction
				)
			else:
				tree.change_scene_to_file(victory_scene_path),
		CONNECT_ONE_SHOT
	)


func update_facing() -> void:
	if _player == null:
		return
	var dir_x : float = get_player_center().x - get_zombie_center().x
	update_facing_direction(dir_x)


func update_facing_direction(dir_x: float) -> void:
	if dir_x > 0:
		sprite.flip_h = false
		sprite.position.x = sprite_pos_facing_right
		emit_signal("facing_direction_changed", true)
	elif dir_x < 0:
		sprite.flip_h = true
		sprite.position.x = sprite_pos_facing_left
		emit_signal("facing_direction_changed", false)
