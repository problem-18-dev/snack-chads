class_name Player
extends CharacterBody2D


signal died

@export_group("Movement")
@export_subgroup("Air")
@export var air_movement_speed := 100.0
@export var air_movement_weight := 0.05
@export var air_coyote_time := 0.1
@export_subgroup("Coyote")
@export var coyote_time := 0.1
@export var coyote_minimum_speed := 125.0 / 2
@export_subgroup("Jump")
@export var jump_force := 450.0
@export_subgroup("Walking")
@export var walk_speed := 125.0
@export var walk_accel := 0.2
@export var walk_deccel := 0.13
@export_subgroup("Running")
@export var run_speed := 175.0
@export var run_accel := 0.2
@export_group("Debug")
@export_subgroup("Movement")
@export var debug_velocity := false

@onready var jump_on_land_ray_cast: RayCast2D = $JumpOnLandRayCast


func _physics_process(_delta: float) -> void:
	if debug_velocity:
		Debug.log("Player velocity: %s" % velocity.round())


func die() -> void:
	died.emit()
	reset()


func reset() -> void:
	global_position = Vector2.ZERO


func get_direction() -> float:
	var direction := Input.get_axis("left", "right")
	return direction


func can_coyote() -> bool:
	return abs(velocity.x) >= coyote_minimum_speed


func set_jump_on_land(jump_on_land: bool) -> void:
	jump_on_land_ray_cast.enabled = jump_on_land
