extends PlayerState
class_name DeadState

var _is_dead : bool = false

func on_enter():
	if _is_dead:
		return
	_is_dead = true
	print("DeadState entered!")
	can_move = false
	character.set_physics_process(false)
	character.set_process_input(false)
	AudioManager.play_music("dead")
	playback.travel("Dead")
	_await_death()

func _await_death():
	print("Waiting for death animation...")
	var anim_player : AnimationPlayer = character.get_node("AnimationPlayer")
	
	if anim_player.has_animation("Dead"):
		var length = anim_player.get_animation("Dead").length
		print("Dead animation length: ", length)
		await character.get_tree().create_timer(length).timeout
	else:
		await character.get_tree().create_timer(1.5).timeout

	print("Death animation done, showing game over")
	PlayerHud.show_game_over()

func on_exit():
	_is_dead = false
	character.set_physics_process(true)
	character.set_process_input(true)

func state_process(_delta):
	pass

func state_input(_event: InputEvent):
	pass
