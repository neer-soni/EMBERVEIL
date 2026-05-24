extends State

func on_enter() -> void:
	can_move = false
	character.velocity = Vector2.ZERO
	# Disable all Area2D children monitoring
	for child in character.get_children():
		if child is Area2D:
			child.monitoring = false
			child.monitorable = false
