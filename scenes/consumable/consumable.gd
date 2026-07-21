class_name Consumable
extends CharacterBody2D

enum Type { ENERGY_DRINK, BACKPACK, LOLLY_POP }

@export_group("Properties")
@export var speed := 40.0
@export var type := Type.BACKPACK
@export var points := 200

var _direction := 0

@onready var detection_area: Area2D = $DetectionArea


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	move_and_slide()
	_handle_collision()


func start() -> void:
	_direction = 1
	detection_area.monitoring = true


func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	velocity.x = _direction * speed


func _handle_collision() -> void:
	if is_on_wall() and sign(get_wall_normal().x) == -sign(_direction):
		_direction *= -1


func _on_detection_area_body_entered(body: Player) -> void:
	body.consume(type)
	GameState.add_points(points, global_position)
	queue_free()
