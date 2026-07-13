extends WalkingEnemy

@onready var timer: Timer = $Timer


func _ready() -> void:
	remove_from_group("enemies")
	stop()


func setup(spawn_position: Vector2) -> void:
	global_position = spawn_position


func stop() -> void:
	super()
	remove_from_group("enemies")


func push(push_direction: int) -> void:
	_direction = push_direction
	timer.start()


func can_be_pushed() -> bool:
	return _is_stopped()


func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == null:
			continue

		if collider.is_in_group("enemies") and not _is_stopped():
			collider.die()
			continue

		var normal := collision.get_normal()

		# If not floor
		if not normal.is_equal_approx(Vector2.UP):
			_direction *= -1


func _on_timer_timeout() -> void:
	add_to_group("enemies")
