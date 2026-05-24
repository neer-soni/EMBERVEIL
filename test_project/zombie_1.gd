extends CharacterBody2D

@onready var animation_tree  : AnimationTree    = $AnimationTree
@onready var state_machine   : StateMachine     = $CharacterStateMachine
@onready var sprite          : Sprite2D         = $Sprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

@export var hit_state    : State
@export var walk_state   : State
@export var chase_state  : ZombieChaseState
@export var attack_state : ZombieAttackState

@export var starting_moving_direction : Vector2 = Vector2.LEFT
@export var movement_speed            : float   = 30.0
@export var detection_range           : float   = 1200.0

@export var sprite_pos_facing_left  : float = 834.0
@export var sprite_pos_facing_right : float = 834.0

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _player : CharacterBody2D = null

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
