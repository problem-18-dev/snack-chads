class_name Projectile
extends CharacterBody2D


@export_group("Properties")
@export var speed := 45.0
@export var bounce_force := 45.0

var _direction: float


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = -bounce_force
	
	velocity.x = speed * _direction
	velocity.y += get_gravity().y * delta
	move_and_slide()
	_handle_collision()


func spawn(spawn_position: Vector2, direction := 1.0) -> void:
	global_position = spawn_position
	_direction = direction


func _destroy() -> void:
	queue_free()


func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		
		if normal.is_equal_approx(Vector2.LEFT) or normal.is_equal_approx(Vector2.RIGHT):
			_destroy()
			return
