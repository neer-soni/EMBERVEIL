extends CharacterBody2D
class_name Player

@export var speed : float = 300.0
@export var max_health : float = 100.0          # ADD THIS
@export var double_jump_velocity : float = -100
# Change to whatever your node is actually named, e.g:
@onready var dead_state : DeadState = $CharacterStateMachine/Dead
@onready var sprite : Sprite2D = $GraphicsRoot/Sprite2D
@onready var graphics_root : Node2D = $GraphicsRoot
@onready var sword : Node2D = $GraphicsRoot/Sword
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : PlayerCharacterStateMachine = $CharacterStateMachine
@onready var damageable_player : Damageable = $DamageablePlayer  # ADD THIS

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO
					  # ADD THIS

@warning_ignore("unused_signal")
signal facing_direction_changed(facing_right : bool)

func _ready():
	animation_tree.active = true
	
	# Set starting health on the Damageable node
	damageable_player.health = max_health
	
	# Find the HUD (must be in group "hud" — see Step 2)
	
	
	# Listen for damage events
	damageable_player.on_hit.connect(_on_player_damaged)
	
	# Draw the bar at full health immediately
	_update_hud()

func _on_player_damaged(_node, _damage_taken, _knockback):
	AudioManager.play_sfx("player_hit")
	_update_hud()
	if damageable_player.health <= 0:
		state_machine.switch_states(dead_state)



func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	direction = Input.get_vector("left", "right", "down", "up")

	if direction.x != 0 && state_machine.check_if_can_move():
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	update_animation()
	update_face_direction()

func update_animation():
	animation_tree.set("parameters/move/blend_position", direction.x)

func update_face_direction():
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
	emit_signal("facing_direction_changed", !sprite.flip_h)

func _update_hud():
	PlayerHud.update_health_bar(damageable_player.health, max_health)
