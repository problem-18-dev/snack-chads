extends WalkingEnemy


func _ready() -> void:
	_stop()


func setup(spawn_position: Vector2) -> void:
	global_position = spawn_position


func push(push_direction: int) -> void:
	if _is_stopped():
		_direction = push_direction
		return
	
	_stop()


func can_be_pushed() -> bool:
	return _is_stopped()


func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == null:
			continue
		
		if collider.is_in_group("enemies"):
			collider.hurt()
			continue
		
		var normal := collision.get_normal()

		# If not floor
		if not normal.is_equal_approx(Vector2.UP):
			_direction *= -1
