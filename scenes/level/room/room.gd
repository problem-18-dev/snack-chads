extends Level


func _spawn_player() -> void:
	var player := _prepare_player()
	
	assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
	start_pipe.start(player)
