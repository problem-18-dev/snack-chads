extends PlayerState


func _physics_update(_delta: float) -> void:
	_process_run_movement()
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(PlayerState.AIR)


func _key_input(event: InputEvent) -> void:
	if event.is_action_released("left") or event.is_action_released("right"):
		finished.emit(PlayerState.WALK)
	
	if event.is_action_released("interact"):
		finished.emit(PlayerState.WALK)
		return
	
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })


func _process_run_movement() -> void:
	var direction := player.get_direction()
	
	player.velocity.x = lerpf(player.velocity.x, player.run_speed * direction, player.run_accel)
