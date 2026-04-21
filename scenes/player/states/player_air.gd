extends PlayerState


func _enter(_data := {}) -> void:
	if _data.has("jump"):
		player.velocity.y = -player.jump_force


func _physics_update(delta: float) -> void:
	player.move_and_slide()
	_process_air_movement()
	_apply_gravity(delta)
	_handle_landing()


func _apply_gravity(delta: float) -> void:
	player.velocity += player.get_gravity() * delta


func _process_air_movement() -> void:
	var direction := player.get_direction()
	
	if is_zero_approx(direction):
		player.velocity.x = lerpf(player.velocity.x, 0, player.air_movement_weight)
		return
	
	var walking := Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var running := Input.is_action_pressed("interact")
	if walking:
		if running:
			var running_air_speed := player.run_speed * direction
			player.velocity.x = lerpf(player.velocity.x, running_air_speed, player.air_movement_weight)
			return
		
		var walking_air_speed := player.walk_speed * direction
		player.velocity.x = lerpf(player.velocity.x, walking_air_speed, player.air_movement_weight)


func _handle_landing() -> void:
	if not player.is_on_floor():
		return
	
	# Run if holding run
	# Walk if not
	# Idle if not moving at all
	var moving := Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var running := Input.is_action_pressed("interact")
	
	if moving:
		if running:
			finished.emit(PlayerState.RUN)
			return
		
		finished.emit(PlayerState.WALK)
		return
		
	finished.emit(PlayerState.IDLE)
