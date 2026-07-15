extends PlayerState

var _is_dead := false


func _enter(data := { }) -> void:
	player.ground_particles.emitting = false
	player.invincibility_timer.paused = true

	if data.has("interactable"):
		_interact(data.interactable)
		return

	if data.has("death"):
		_die()
		return

	if data.has("walk_to"):
		_walk_to(data.walk_to)


func _exit() -> void:
	player.invincibility_timer.paused = false


func _interact(interactable: Interactable) -> void:
	player.sprite.play("idle")
	interactable.interact()


func _die() -> void:
	_is_dead = true
	player.sprite.play("death")
	player.collision_shape.set_deferred("disabled", true)
	player.invincible_area.monitoring = false

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var jump_distance = Vector2.UP * player.death_jump_distance
	tween.tween_property(player, "position", player.position + jump_distance, player.death_duration).set_delay(player.death_pause)
	tween.tween_property(player, "position", player.position - jump_distance, player.death_duration)
	await tween.finished

	player.died.emit()


func _walk_to(destination: Vector2) -> void:
	player.sprite.flip_h = false
	player.sprite.play("walk")
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(player, "global_position", destination, player.walk_to_duration)
	tween.tween_callback(player.sprite.play.bind("idle"))
	await tween.finished
	await get_tree().create_timer(player.time_before_end).timeout
	player.finished_level.emit()
