extends PlayerState


func _enter(_data := {}) -> void:
	player.velocity = Vector2.ZERO


func _physics_update(_delta: float) -> void:
	player.move_and_slide()
	_handle_collision()


func _key_input(event: InputEvent) -> void:
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
			if collider.is_in_group("pushables") and collider.can_be_pushed():
				player.push_enemy(collider)
				continue
			
			player.hurt()
