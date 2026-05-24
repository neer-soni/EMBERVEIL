extends Area2D

class_name ZombieHitbox2

@export var damage          : int   = 20
@export var knockback_speed : float = 300.0
@export var zombie          : CharacterBody2D
@export var facing_shape    : HitboxFacingShape2

var _zombie_dead : bool = false


func _ready() -> void:
	monitoring = false
	if zombie and zombie.has_signal("facing_direction_changed"):
		zombie.connect("facing_direction_changed", _on_facing_direction_changed)

	if zombie:
		for child in zombie.get_children():
			if child is Damageable:
				child.connect("on_hit", _on_zombie_hit)
				break


func _on_zombie_hit(_node: Node, _damage: int, _dir: Vector2) -> void:
	for child in zombie.get_children():
		if child is Damageable:
			if child.get_health() <= 0:
				_zombie_dead = true
				set_deferred("monitoring", false)
				set_deferred("monitorable", false)
			break


func _on_facing_direction_changed(facing_right: bool) -> void:
	if _zombie_dead:
		return
	if facing_shape == null:
		return
	if facing_right:
		facing_shape.position = facing_shape.facing_right_position
	else:
		facing_shape.position = facing_shape.facing_left_position


func _on_body_entered(body: Node) -> void:
	# Do not deal damage if zombie is dead
	if _zombie_dead:
		return
	if not body is Player:
		return
	# Also guard against the zombie node being freed
	if not is_instance_valid(zombie):
		return
	for child in body.get_children():
		if child is Damageable:
			var dir_sign : float = sign(body.global_position.x - zombie.global_position.x)
			child.hit(damage, Vector2(dir_sign, 0.0))
			break
