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
	AudioManager.play_sfx(AudioManager.Sfx.BIKE_PUSH)
	timer.start()


func can_be_pushed() -> bool:
	return _is_stopped()


func _handle_collision() -> void:
	if is_on_wall() and sign(get_wall_normal().x) == -sign(_direction):
		_direction *= -1

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == null:
			continue

		if collider.is_in_group("enemies") and not _is_stopped():
			AudioManager.play_sfx(AudioManager.Sfx.STOMP)
			collider.die()


func _on_timer_timeout() -> void:
	add_to_group("enemies")
