extends Node

func _ready():
	var s = State.new()       # C++ State
	print("State: ", s)
	print("can_move: ", s.can_move)  # should print true
	s.queue_free()
