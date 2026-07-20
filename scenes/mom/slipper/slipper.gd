extends Area2D

@export_group("Movement")
@export var movement_speed := 120.0
@export_group("Rotation")
@export var rotation_speed := 5.0

var _can_be_destroyed := false

@onready var sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	sprite.rotation += rotation_speed * delta


func _physics_process(delta: float) -> void:
	global_position.x -= movement_speed * delta


func start(start_position) -> void:
	global_position = start_position


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_can_be_destroyed = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if _can_be_destroyed:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	body.take_damage()
