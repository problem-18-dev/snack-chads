extends PlayerState


var _coyote := false
var _should_jump_on_land := false

@onready var coyote_timer: Timer = $CoyoteTimer


func _enter(data := {}) -> void:
	player.set_jump_on_land(true)
	
	if data.has("jump"):
		_jump()
	
	if data.has("coyote") and data.coyote:
		_enable_coyote()


func _exit() -> void:
	_disable_coyote()
	player.set_jump_on_land(false)


func _physics_update(delta: float) -> void:
	var has_collided := player.move_and_slide()
	_process_air_movement()
	_apply_gravity(delta)
	_handle_landing()
	_handle_collision(has_collided)


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and _coyote:
		_jump()


func _apply_gravity(delta: float) -> void:
	if _coyote:
		return
	
	player.velocity += player.get_gravity() * delta


func _process_air_movement() -> void:
	if _coyote:
		return
	
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
	_check_jump_on_land()
	
	if not player.is_on_floor():
		return
	
	if _should_jump_on_land:
		_jump()
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


func _jump() -> void:
	player.velocity.y = -player.jump_force
	_disable_coyote()
	_set_jump_on_land(false)


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
		return


func _handle_collision(has_collided: bool) -> void:
	if not has_collided:
		return
		
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var normal := collision.get_normal()
		
		if normal.is_equal_approx(Vector2.DOWN):
			var collider := collision.get_collider()
			if collider is SurpriseBlock:
				_check_hit_raycasts()


func _check_hit_raycasts() -> void:
	for hit_ray_cast in player.hit_raycasts:
		if hit_ray_cast.is_colliding():
			var collider := hit_ray_cast.get_collider()
			collider.hit()


func _on_coyote_timer_timeout() -> void:
	_disable_coyote()
