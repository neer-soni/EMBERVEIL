extends Node


class_name damageable3

signal on_hit(_node : Node, _damage_taken : int, knockback_direction : Vector2)






@export var health : float = 100:
	get :
		return health
	set(value):
		SignalBus.emit_signal("on_health_changed", get_parent(),value - health)
		health = value

@export var _dead_animation_name : String = "dead"

func hit(damage : int, knockback_direction: Vector2):
	health -= damage
	emit_signal("on_hit", get_parent(), damage, knockback_direction)
	
	


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == _dead_animation_name):
		#character is finished and dying
		get_parent().queue_free()
