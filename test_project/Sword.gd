extends Area2D

@export var damage       : int                = 10
@export var player       : Player
@export var facing_shape : FacingCollisionShape
@export var Player_shape : PLayerPosition

var _already_hit : Array[Node] = []

func _ready() -> void:
	monitoring = false
	# Clear hit list whenever monitoring turns off (swing ends)
	player.connect("facing_direction_changed", _on_player_facing_direction_changed)

func _physics_process(_delta: float) -> void:
	# When monitoring turns off, clear the hit list for next swing
	if not monitoring:
		_already_hit.clear()

func _on_body_entered(body: Node) -> void:
	if body in _already_hit:
		return
	_already_hit.append(body)

	for child in body.get_children():
		if child is Damageable:
			AudioManager.play_sfx("enemy_hit")
			var dir : Vector2 = body.global_position - get_parent().global_position
			var dir_sign : float = sign(dir.x)

			if dir_sign > 0:
				child.hit(damage, Vector2.RIGHT)
			elif dir_sign < 0:
				child.hit(damage, Vector2.LEFT)
			else:
				child.hit(damage, Vector2.ZERO)
			break

func _on_player_facing_direction_changed(facing_right: bool) -> void:
	if facing_right:
		facing_shape.position = facing_shape.facing_right_position
		Player_shape.position = Player_shape.facing_right_position
	else:
		facing_shape.position = facing_shape.facing_left_position
		Player_shape.position = Player_shape.facing_left_position
# Add this method to the sword script
func play_swing_sound():
	AudioManager.play_sfx("sword_swing")
