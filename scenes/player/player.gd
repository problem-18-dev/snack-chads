class_name Player
extends CharacterBody2D


signal died

@export_group("Movement")
@export_subgroup("Jump")
@export var jump_force := 450.0
@export_subgroup("Running")
@export var run_speed := 150.0


func _physics_process(_delta: float) -> void:
	_handle_movement()


func die() -> void:
	died.emit()
	reset()


func reset() -> void:
	global_position = Vector2.ZERO


func _handle_movement() -> void:
	var direction := Input.get_axis("left", "right")
	if is_zero_approx(direction):
		velocity.x = 0
		return
	
	velocity.x = direction * run_speed
