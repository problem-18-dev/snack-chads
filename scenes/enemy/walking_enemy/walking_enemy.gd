class_name WalkingEnemy
extends Enemy

@export_group("Movement")
@export var speed := 20.0
@export_group("Death")
@export var death_bump_force := -150.0
@export var death_rotation_speed := 8.0

var _direction := -1
var _is_dead := false

@onready var _current_speed := 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _process(delta: float) -> void:
	if not _is_dead:
		return

	sprite.rotation += death_rotation_speed * delta


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_process_movement()
	move_and_slide()
	_handle_collision()


func setup(_spawn_position: Vector2) -> void:
	pass


func pause() -> void:
	if _is_dead:
		return

	_current_speed = 0
	set_collision_layer_value(6, false)


func resume() -> void:
	if _is_dead:
		return

	_current_speed = speed
	set_collision_layer_value(6, true)


func hurt() -> void:
	if debug_enabled:
		Debug.log("Walking enemy hurt!")

	if _is_dead:
		return

	die()


func die() -> void:
	_is_dead = true
	remove_from_group("enemies")
	set_collision_layer_value(6, false) # Enemies
	set_collision_mask_value(2, false) # Hittables
	set_collision_mask_value(5, false) # World
	set_collision_mask_value(6, false) # Other enemies
	velocity.y = death_bump_force
	sprite.play("death")


func stop() -> void:
	_direction = 0


func _is_stopped() -> bool:
	return _direction == 0


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func _process_movement() -> void:
	if _is_dead:
		velocity.x = 0
		return

	velocity.x = _direction * _current_speed

	if not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0


func _handle_collision() -> void:
	if _is_dead:
		return

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == null:
			continue

		var normal := collision.get_normal()

		# If not floor
		if not normal.is_equal_approx(Vector2.UP):
			_direction *= -1
