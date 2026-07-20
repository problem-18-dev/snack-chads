extends PlayerState


func _enter(_data := { }) -> void:
	player.velocity = Vector2.ZERO
	player.sprite.play("idle")
	player.ground_particles.emitting = false


func _physics_update(_delta: float) -> void:
	if not is_zero_approx(player.get_direction()):
		finished.emit(PlayerState.WALK)

	player.move_and_slide()
	_handle_collision()


func _key_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })
		return

	if event.is_action_pressed("left") or event.is_action_pressed("right"):
		finished.emit(PlayerState.WALK)
		return

	if event.is_action_pressed("down"):
		player.attempt_interaction()


func _handle_collision() -> void:
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var collider := collision.get_collider()

		if collider.is_in_group("enemies"):
			if player.is_energized:
				collider.die()
				continue

			player.take_damage()
