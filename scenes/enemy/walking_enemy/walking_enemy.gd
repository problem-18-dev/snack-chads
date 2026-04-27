class_name WalkingEnemy
extends Enemy


@export_group("Movement")
@export var speed := 20.0

@onready var sprite: Sprite2D = $Sprite2D


var _direction := -1


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_process_movement()
	var has_collided := move_and_slide()
	_handle_collision(has_collided)


func hurt() -> void:
	if debug_enabled:
		Debug.log("Walking enemy hurt!")
	
	queue_free()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func _process_movement() -> void:
	velocity.x = _direction * speed
	
	if not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0


func _handle_collision(has_collided: bool) -> void:
	if not has_collided:
		return
		
	var collisions := get_slide_collision_count()
	
	for i in collisions:
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == null:
			continue
		
		var normal := collision.get_normal()

		# If not floor
		if not normal.is_equal_approx(Vector2.UP):
			_direction *= -1
