class_name WalkingEnemy
extends Enemy


@export_group("Movement")
@export var speed := 20.0

var _current_speed := speed
var _direction := -1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_process_movement()
	move_and_slide()
	_handle_collision()


func setup(_spawn_position: Vector2) -> void:
	pass


func pause() -> void:
	_current_speed = 0
	set_collision_layer_value(5, false)


func resume() -> void:
	_current_speed = speed
	set_collision_layer_value(5, true)


func hurt() -> void:
	if debug_enabled:
		Debug.log("Walking enemy hurt!")
	
	queue_free()


func _stop() -> void:
	_direction = 0


func _is_stopped() -> bool:
	return _direction == 0


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func _process_movement() -> void:
	velocity.x = _direction * _current_speed
	
	if not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0


func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == null:
			continue
		
		var normal := collision.get_normal()

		# If not floor
		if not normal.is_equal_approx(Vector2.UP):
			_direction *= -1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):
		body.queue_free()
		hurt()
