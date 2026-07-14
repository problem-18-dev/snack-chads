extends PlayerState

const DEATH_JUMP_FORCE := 250.0

var _is_dead := false


func _enter(data := { }) -> void:
	player.ground_particles.emitting = false
	player.invincibility_timer.paused = true

	if data.has("interactable"):
		_interact(data.interactable)
		return

	if data.has("death"):
		_die()

	if data.has("walk_to"):
		_walk_to(data.walk_to)


func _exit() -> void:
	player.invincibility_timer.paused = false


func _physics_update(delta: float) -> void:
	if not _is_dead:
		return

	_apply_gravity(delta)
	player.move_and_slide()


func _interact(interactable: Interactable) -> void:
	player.sprite.play("idle")
	interactable.interact()


func _die() -> void:
	_is_dead = true
	player.sprite.play("death")
	player.velocity = Vector2(0, -DEATH_JUMP_FORCE)
	player.collision_shape.set_deferred("disabled", true)
	player.invincible_area.monitoring = false


func _walk_to(destination: Vector2) -> void:
	player.sprite.flip_h = false
	player.sprite.play("walk")
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(player, "global_position", destination, player.walk_to_duration)
	tween.tween_callback(player.sprite.play.bind("idle"))


func _apply_gravity(delta: float) -> void:
	var death_gravity := player.get_gravity().y / 2
	player.velocity.y += death_gravity * delta
