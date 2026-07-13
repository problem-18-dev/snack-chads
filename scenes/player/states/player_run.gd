extends PlayerState


func _enter(_data := { }) -> void:
	player.sprite.play("run")
	player.ground_particles.emitting = true
	_check_input()


func _physics_update(_delta: float) -> void:
	_process_run_movement()
	player.move_and_slide()
	_handle_collision()

	if not player.is_on_floor():
		finished.emit(PlayerState.AIR, { "coyote": player.can_coyote() })


func _key_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_released("interact"):
		finished.emit(PlayerState.WALK)
		return

	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true, "is_running": true })


func _process_run_movement() -> void:
	var direction := player.get_direction()
	player.velocity.x = lerpf(player.velocity.x, player.run_speed * direction, player.run_accel)


func _handle_collision() -> void:
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var collider := collision.get_collider()

		if collider.is_in_group("pushables") and collider.can_be_pushed():
			player.push_enemy(collider)
			continue

		if collider.is_in_group("enemies"):
			if player.is_invulnerable:
				collider.die()
				continue

			player.take_damage()


### Test
func _check_input() -> void:
	if Input.is_action_pressed("interact"):
		return

	if player.is_on_floor():
		finished.emit(PlayerState.AIR)
		return

	finished.emit(PlayerState.WALK)
