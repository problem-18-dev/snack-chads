class_name Player
extends CharacterBody2D


signal died

@export_group("Movement")
@export_subgroup("Air")
@export var air_movement_speed := 100.0
@export var air_movement_weight := 0.025
@export_subgroup("Jump")
@export var jump_force := 450.0
@export_subgroup("Walking")
@export var walk_speed := 125.0
@export var walk_accel := 0.2
@export var walk_deccel := 0.13
@export_subgroup("Running")
@export var run_speed := 175.0
@export var run_accel := 0.27


func _physics_process(_delta: float) -> void:
	Debug.log("Player velocity: " + str(velocity.floor()))


func die() -> void:
	died.emit()
	reset()


func reset() -> void:
	global_position = Vector2.ZERO


func get_direction() -> float:
	var direction := Input.get_axis("left", "right")
	return direction
