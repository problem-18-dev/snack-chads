extends PlayerState

var _coyote := false
var _should_jump_on_land := false

@onready var coyote_timer: Timer = $CoyoteTimer


func _enter(data := { }) -> void:
	player.ground_particles.emitting = false
	player.set_jump_on_land(true)

	if data.has("jump"):
		var is_running := data.has("is_running")
		_jump(is_running)

	if data.has("coyote") and data.coyote:
		_enable_coyote()


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	_process_air_movement()

	player.move_and_slide()
	var should_handle_landing := _handle_collision()

	if should_handle_landing:
		_handle_landing()


func _key_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("jump") and _coyote:
		_jump()

	if event.is_action_released("jump") and player.velocity.y < 0:
		_jump_release()


func _apply_gravity(delta: float) -> void:
	player.velocity += player.get_gravity() * delta


func _process_air_movement() -> void:
	if _coyote:
		return

	if player.velocity.y > 0:
		player.sprite.play("air_down")
	else:
		player.sprite.play("air_up")

	var direction := player.get_direction()
	if is_zero_approx(direction):
		player.velocity.x = lerpf(player.velocity.x, 0, player.air_movement_weight)
		return

	var moving := Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var running := Input.is_action_pressed("interact")
	if moving:
		if running:
			var running_air_speed := player.run_speed * direction
			player.velocity.x = lerpf(player.velocity.x, running_air_speed, player.air_movement_weight)
			return

		var walking_air_speed := player.walk_speed * direction
		player.velocity.x = lerpf(player.velocity.x, walking_air_speed, player.air_movement_weight)


## Handles collision, returns true if player should check landing
func _handle_collision() -> bool:
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == null:
			continue

		var normal := collision.get_normal()

		# Blocks
		if collider.is_in_group("blocks"):
			_check_block_hits(normal)
			continue

		# Enemies
		if collider.is_in_group("enemies") or collider.is_in_group("pushables"):
			if player.is_energized:
				collider.die()
				return true

			_check_enemy_hits(collider, normal)
			return false

	return true


func _check_block_hits(normal: Vector2) -> void:
	var is_under_block := Vector2.DOWN.dot(normal) > 0.1
	if not is_under_block:
		return

	for hit_ray_cast in player.hit_raycasts:
		if not hit_ray_cast.is_colliding():
			continue

		var collider: Block = hit_ray_cast.get_collider()
		if player.can_destroy_blocks():
			collider.hit()
			continue

		collider.bump()


func _check_enemy_hits(collider: CharacterBody2D, normal: Vector2) -> void:
	var is_on_head := Vector2.UP.dot(normal) > 0.1

	if not is_on_head:
		player.take_damage()
		return

	if collider.is_in_group("pushables"):
		AudioManager.play_sfx(AudioManager.Sfx.STOMP)
		collider.stop()
		_bounce()
		return

	if collider.has_method("hurt"):
		AudioManager.play_sfx(AudioManager.Sfx.STOMP)
		player.player_camera.screen_shake(PlayerCamera.SMALL_INTENSITY, PlayerCamera.SHORT_LENGTH)
		collider.hurt()
	else:
		player.take_damage()
	_bounce()


func _handle_landing() -> void:
	_check_jump_on_land()

	if not player.is_on_floor():
		return

	if _should_jump_on_land:
		_jump()
		return

	player.elastic_land_component.use()
	player.land_particles.emitting = true
	# Run if holding run
	# Walk if not
	# Idle if not moving at all
	var moving := Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var running := Input.is_action_pressed("interact")

	if moving and running:
		finished.emit(PlayerState.RUN)
		return

	finished.emit(PlayerState.WALK)


func _jump(is_running := false) -> void:
	AudioManager.play_sfx(AudioManager.Sfx.JUMP)

	if is_running:
		player.velocity.y = -player.jump_running_force
	else:
		player.velocity.y = -player.jump_force

	_disable_coyote()
	_set_jump_on_land(false)


func _bounce() -> void:
	if Input.is_action_pressed("jump"):
		player.velocity.y = -player.bounce_force * player.bounce_force_multiplier
		return

	player.velocity.y = -player.bounce_force


func _jump_release() -> void:
	player.velocity.y /= player.jump_release_divider


func _enable_coyote() -> void:
	_coyote = true
	coyote_timer.start(player.coyote_time)
	if player.debug_coyote:
		Debug.log("Entered coyote")


func _disable_coyote() -> void:
	if not _coyote:
		return

	_coyote = false
	if player.debug_coyote:
		Debug.log("Exit coyote")


func _set_jump_on_land(jump_on_land: bool) -> void:
	_should_jump_on_land = jump_on_land


func _check_jump_on_land() -> void:
	var is_colliding := func is_colliding(ray_cast: RayCast2D): return ray_cast.is_colliding()
	var is_close_to_floor := player.jump_buffer_ray_casts.any(is_colliding)
	var is_falling := player.velocity.y > 0

	if Input.is_action_just_pressed("jump") and is_close_to_floor and is_falling:
		_set_jump_on_land(true)


func _on_coyote_timer_timeout() -> void:
	_disable_coyote()
