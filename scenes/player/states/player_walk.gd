extends PlayerState


func _physics_update(_delta: float) -> void:
	_process_walk_movement()
	player.move_and_slide()
	
	
	if not player.is_on_floor():
		finished.emit(PlayerState.AIR, { "coyote": player.can_coyote() })

func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })
		return
	
	if event.is_action_pressed("interact"):
		finished.emit(PlayerState.RUN)


func _process_walk_movement() -> void:
	var direction := player.get_direction()
	
	if is_zero_approx(direction):
		player.velocity.x = lerpf(player.velocity.x, 0, player.walk_deccel)
		
		if is_zero_approx(player.velocity.x):
			finished.emit(PlayerState.IDLE)
		
		return
	
	player.velocity.x = lerpf(player.velocity.x, player.walk_speed * direction, player.walk_accel)
