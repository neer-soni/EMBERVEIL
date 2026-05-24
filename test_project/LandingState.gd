extends PlayerState

@export var Landing_animation_name : String = "landing"
@export var ground_state : PlayerState
func _on_animation_tree_animation_finished(_anim_name):
	if(_anim_name == Landing_animation_name):
		next_state = ground_state
