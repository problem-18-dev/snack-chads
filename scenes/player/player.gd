class_name Player
extends CharacterBody2D


signal died

@export_group("Movement")
@export_subgroup("Air")
@export var air_movement_speed := 100.0
@export var air_movement_weight := 0.05
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
@export var debug_coyote := false
@export var debug_state := false

@onready var jump_buffer_ray_casts: Array[RayCast2D] = [
	$Raycasts/LeftJumpBufferRayCast,
	$Raycasts/RightJumpBufferRayCast
	]
@onready var hit_raycasts: Array[RayCast2D] = [$Raycasts/LeftUpperHitRaycast, $Raycasts/RightUpperHitRaycast]
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	_debug_states()


func _physics_process(_delta: float) -> void:
	_debug_velocity()


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


func set_jump_on_land(jump_buffer_enabled: bool) -> void:
	for jump_buffer_ray_cast in jump_buffer_ray_casts:
		jump_buffer_ray_cast.enabled = jump_buffer_enabled


func _debug_states() -> void:
	if not debug_state:
		return
	
	for state: State in find_children("*", "State"):
		state.finished.connect(_on_state_finished_debug)


func _debug_velocity() -> void:
	if not OS.is_debug_build() or not debug_velocity:
		return
	
	Debug.log("Player velocity: %s" % velocity.round())


func _on_state_finished_debug(state: String, data := {}) -> void:
	if data.size() > 0:
		Debug.log("Player state changed to %s with %s" % [state, data])
		return
	
	Debug.log("Player state changed to %s" % state)
