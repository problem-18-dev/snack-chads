extends Level


func _spawn_player() -> void:
	var player: Player = PLAYER_PACKED.instantiate()
	add_child(player)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := (level_size.size.x * tile_size.x) - 48
	player.setup(limit_left, limit_right)
	
	assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
	start_pipe.start(player)
