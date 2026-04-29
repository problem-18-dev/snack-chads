class_name Player
extends CharacterBody2D


signal died

@export_group("Movement")
@export_subgroup("Air")
@export var air_movement_weight := 0.05
@export_subgroup("Coyote")
@export var coyote_time := 0.1
@export var coyote_minimum_speed := 125.0 / 2
@export_subgroup("Jump")
@export var jump_force := 375.0
@export var jump_running_force := 400.0
@export_range(1, 2, 0.01) var jump_release_divider := 1.5
@export_subgroup("Walking")
@export var walk_speed := 125.0
@export var walk_accel := 0.2
@export var walk_deccel := 0.15
@export_subgroup("Running")
@export var run_speed := 175.0
@export var run_accel := 0.2
@export_group("Collisions")
@export var bounce_force := 150.0
@export var bounce_force_multiplier := 3.0
@export_group("Interactions")
@export var pipe_maximum_speed := 10.0
@export_group("Debug")
@export_subgroup("Movement")
@export var debug_velocity := false
@export var debug_coyote := false
@export var debug_movement_limit := false
@export_subgroup("Power Ups")
@export var debug_power_ups := false
@export_subgroup("State machine")
@export var debug_state := false

var is_grown := false

var _interactable: Interactable

@onready var jump_buffer_ray_casts: Array[RayCast2D] = [
	$Raycasts/LeftJumpBufferRayCast,
	$Raycasts/RightJumpBufferRayCast
	]
@onready var hit_raycasts: Array[RayCast2D] = [$Raycasts/LeftUpperHitRaycast, $Raycasts/RightUpperHitRaycast]
@onready var state_machine: StateMachine = $StateMachine
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_debug_states()


func _physics_process(_delta: float) -> void:
	_limit_movement()
	_flip_sprite()
	_debug_velocity()


func setup(spawn_position: Vector2, limit_left: int, limit_right: int) -> void:
	global_position = spawn_position
	player_camera.setup(limit_left, limit_right)


func hurt() -> void:
	if is_grown:
		shrink()
		return
	
	if debug_power_ups:
		Debug.log("Player died!")
	
	die()


func die() -> void:
	died.emit()
	reset()


func grow() -> void:
	if is_grown:
		return
	
	is_grown = true
	animation_player.play("grow")
	
	if debug_power_ups:
		Debug.log("Player grows!")


func shrink() -> void:
	is_grown = false
	animation_player.play("shrink")
	
	if debug_power_ups:
		Debug.log("Player shrinks!")


func consume(type: String) -> void:
	match type:
		"grow":
			grow()
		_:
			push_error("Consumable type not found", type)


func is_slow() -> bool:
	return abs(velocity.x) < pipe_maximum_speed


func reset() -> void:
	global_position = Vector2.ZERO


func get_direction() -> float:
	var direction := Input.get_axis("left", "right")
	return direction


func can_coyote() -> bool:
	return abs(velocity.x) >= coyote_minimum_speed


func can_hit() -> bool:
	return is_grown


func set_jump_on_land(jump_buffer_enabled: bool) -> void:
	for jump_buffer_ray_cast in jump_buffer_ray_casts:
		jump_buffer_ray_cast.enabled = jump_buffer_enabled


func set_interactable(interactable: Interactable) -> void:
	assert(interactable is Interactable, "Setting interactable on player but object isn't Interactable.")
	_interactable = interactable


func unset_interactable() -> void:
	if not _interactable:
		return
	_interactable = null


func attempt_interaction() -> void:
	if _interactable:
		state_machine.transition_to_state(PlayerState.IMMOBILE, {"interactable": _interactable})


func push_enemy(enemy: Enemy) -> void:
	var push_direction := -1 if sprite.flip_h else 1
	enemy.push(push_direction)


func _limit_movement() -> void:
	var limit_left := player_camera.limit_left
	var limit_right := player_camera.limit_right
	var current_position := global_position.x
	current_position = clamp(current_position, limit_left, limit_right)
	
	if is_equal_approx(current_position, limit_left):
		global_position.x = limit_left
		velocity.x = 0
	
	if is_equal_approx(current_position, limit_right):
		global_position.x = limit_right
		velocity.x = 0
	
	if debug_movement_limit:
		Debug.log("Boundary hit")


func _flip_sprite() -> void:
	var direction := get_direction()
	if is_zero_approx(direction):
		return
	
	sprite.flip_h = direction < 0


func _debug_states() -> void:
	if not debug_state:
		return
	
	for state: State in find_children("*", "State"):
		state.finished.connect(_on_state_finished_debug)


func _debug_velocity() -> void:
	if not debug_velocity:
		return
	
	Debug.log("Player velocity: %s" % velocity.round())


func _on_state_finished_debug(state: String, data := {}) -> void:
	if data.size() > 0:
		Debug.log("Player state changed to %s with %s" % [state, data])
		return
	
	Debug.log("Player state changed to %s" % state)
