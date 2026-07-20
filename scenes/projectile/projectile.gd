class_name Projectile
extends CharacterBody2D

@export_group("Properties")
@export var speed := 120.0
@export var bounce_force := 45.0
@export var rotation_speed := 12.0

var _direction: float
var _extra_velocity: float

@onready var sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	sprite.rotation += rotation_speed * delta


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = -bounce_force

	velocity.x = (speed + _extra_velocity) * _direction
	_extra_velocity = maxf(0, _extra_velocity - delta)
	velocity.y += get_gravity().y * delta
	move_and_slide()
	_handle_collision()


func spawn(spawn_position: Vector2, direction := 1.0, extra_velocity := 0.0) -> void:
	global_position = spawn_position
	_direction = direction
	_extra_velocity = absf(extra_velocity)


func die() -> void:
	_destroy()


func _destroy() -> void:
	queue_free()


func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider.is_in_group("enemies") or collider.is_in_group("pushables"):
			AudioManager.play_sfx(AudioManager.Sfx.STOMP)
			collider.die()
			_destroy()
			return

		var normal := collision.get_normal()
		if normal.is_equal_approx(Vector2.LEFT) or normal.is_equal_approx(Vector2.RIGHT):
			_destroy()
