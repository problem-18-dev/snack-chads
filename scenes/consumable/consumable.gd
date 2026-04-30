class_name Consumable
extends CharacterBody2D


@export var speed := 40.0
@export var type := "grow"

var _direction := 0

@onready var detection_area: Area2D = $DetectionArea


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	velocity.x = _direction * speed
	move_and_slide()
	_handle_collision()


func start() -> void:
	_direction = 1
	detection_area.monitoring = true


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


func _on_detection_area_body_entered(body: Player) -> void:
	body.consume(type)
	queue_free()
