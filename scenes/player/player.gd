class_name Player
extends CharacterBody2D

signal died
signal fired
signal consumed
signal started
signal finished_level

enum PlayerMode { Normal, Large, Fire }

const PROJECTILE: PackedScene = preload("uid://dvmwy36oldp5")
const INVINCIBILITY_SHADER: Shader = preload("uid://u1wm04bxa3qy")
const PLAYER_RESOURCES := {
	PlayerMode.Normal: preload("uid://bkxnhau8jvgdv"),
	PlayerMode.Large: preload("uid://bqgwcyojoi3a1"),
	PlayerMode.Fire: preload("uid://dcsb3nuldr7a7"),
}

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
@export_group("Player Mode")
@export var consume_duration := 0.5
@export var hurt_duration := 1.5
@export_subgroup("Invincibility")
@export var invincibility_duration := 10.0
@export_group("Death")
@export var death_jump_force := 250.0
@export_group("End")
@export var walk_to_duration := 3.0
@export var time_before_end := 2.0
@export_group("Debug")
@export_subgroup("Movement")
@export var debug_velocity := false
@export var debug_coyote := false
@export var debug_movement_limit := false
@export_subgroup("Points")
@export var debug_points := false
@export_subgroup("Player Mode")
@export var debug_player_mode := false
@export_subgroup("State machine")
@export var debug_state := false

var player_mode := PlayerMode.Normal
var is_invulnerable := false
var _interactable: Interactable
var _can_shoot := false

@onready var jump_buffer_ray_casts: Array[RayCast2D] = [
	$Raycasts/LeftJumpBufferRayCast,
	$Raycasts/RightJumpBufferRayCast,
]
@onready var hit_raycasts: Array[RayCast2D] = [$Raycasts/LeftUpperHitRaycast, $Raycasts/RightUpperHitRaycast]
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_marker: Marker2D = $ShootMarker
@onready var invincible_area: Area2D = $InvincibleArea
@onready var shoot_cooldown_timer: Timer = $ShootCooldownTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var player_mode_timer: Timer = $PlayerModeTimer
@onready var ground_particles: CPUParticles2D = $AnimatedSprite2D/GroundParticles
@onready var star_particles: CPUParticles2D = $AnimatedSprite2D/StarParticles


func _ready() -> void:
	_debug_states()
	_prepare()


func _physics_process(_delta: float) -> void:
	_limit_movement()
	_flip_sprite()
	_debug_velocity()


func start() -> void:
	state_machine.transition_to_state(PlayerState.AIR)


func spawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	player_camera.align()
	player_camera.reset_smoothing()


func setup_camera(limit_left: int, limit_right: int) -> void:
	player_camera.setup(limit_left, limit_right)


func take_damage() -> void:
	if player_mode == PlayerMode.Normal:
		die()
		return

	_flicker(hurt_duration)
	_downgrade_player_mode()


func die() -> void:
	died.emit()
	state_machine.transition_to_state(PlayerState.IMMOBILE, { "death": true })


func consume(consumable: Consumable.Type) -> void:
	match consumable:
		Consumable.Type.ENERGY_DRINK:
			enable_invincibility()
		Consumable.Type.BACKPACK:
			_upgrade_player_mode(PlayerMode.Large)
		Consumable.Type.LOLLY_POP:
			_upgrade_player_mode(PlayerMode.Fire)
		_:
			push_error("Consumable not handled: ", consumable)


func grow_normal() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.Normal].sprite_frames
	animation_player.play("shrink")

	if debug_player_mode:
		Debug.log("Player grows normal")


func grow_large() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.Large].sprite_frames
	animation_player.play("large")

	if debug_player_mode:
		Debug.log("Player grows large")


func enable_fire() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.Fire].sprite_frames
	animation_player.play("fire")
	_can_shoot = true

	if debug_player_mode:
		Debug.log("Player is in fire mode!")


func is_slow() -> bool:
	return abs(velocity.x) < pipe_maximum_speed


func is_grown() -> bool:
	return player_mode != PlayerMode.Normal


func reset() -> void:
	spawn(Vector2.ZERO)


func shoot() -> void:
	if player_mode != PlayerMode.Fire or not _can_shoot:
		return

	var projectile: Projectile = PROJECTILE.instantiate()
	var direction := -1 if sprite.flip_h else 1
	projectile.spawn(shoot_marker.global_position, direction, velocity.x)
	get_tree().root.add_child(projectile)

	_can_shoot = false
	shoot_cooldown_timer.start()


func get_direction() -> float:
	var direction := Input.get_axis("left", "right")
	return direction


func can_coyote() -> bool:
	return abs(velocity.x) >= coyote_minimum_speed


func can_destroy_blocks() -> bool:
	return is_grown()


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
	if not _interactable:
		return

	state_machine.transition_to_state(PlayerState.IMMOBILE, { "interactable": _interactable })


func push_enemy(enemy: Enemy) -> void:
	var push_direction := -1 if sprite.flip_h else 1
	enemy.push(push_direction)


func set_player_mode(new_player_mode: PlayerMode) -> void:
	match new_player_mode:
		PlayerMode.Large:
			grow_large()
		PlayerMode.Fire:
			enable_fire()
		_:
			grow_normal()

	player_mode = new_player_mode


func get_remaining_invincibility_time() -> float:
	if invincibility_timer.is_stopped():
		return 0.0

	return invincibility_timer.time_left


func enable_invincibility(duration := invincibility_duration) -> void:
	if is_zero_approx(duration):
		return

	if debug_player_mode:
		Debug.log("Player is in star mode for %s sec!" % duration)

	is_invulnerable = true
	invincible_area.monitoring = true
	invincibility_timer.start(duration)
	sprite.material.shader = INVINCIBILITY_SHADER
	star_particles.emitting = true


func walk_to(destination: Vector2) -> void:
	state_machine.transition_to_state(PlayerState.IMMOBILE, { "walk_to": destination })


func _upgrade_player_mode(new_player_mode: PlayerMode) -> void:
	consumed.emit()

	# Save state, pause player
	var previous_state := state_machine.get_current_state()
	_pause()

	if new_player_mode > player_mode:
		player_mode_timer.start(consume_duration)

		set_player_mode(new_player_mode)
		await player_mode_timer.timeout
	elif new_player_mode <= player_mode:
		# Bonus points
		pass

	_unpause(previous_state)
	started.emit()


func _downgrade_player_mode() -> void:
	var previous_state := state_machine.get_current_state()
	_pause()
	player_mode_timer.start(hurt_duration)

	set_player_mode(player_mode - 1)

	await player_mode_timer.timeout
	_unpause(previous_state)


func _pause() -> void:
	state_machine.transition_to_state(PlayerState.IMMOBILE)
	invincibility_timer.paused = true


func _unpause(resume_state: String) -> void:
	invincibility_timer.paused = false
	state_machine.transition_to_state(resume_state)


func _prepare() -> void:
	sprite.material.shader = null
	invincible_area.monitoring = false
	invincibility_timer.wait_time = invincibility_duration


func _flicker(duration: float) -> void:
	var tween := create_tween().set_loops(0)
	tween.tween_property(sprite, "visible", false, 0.1)
	tween.tween_property(sprite, "visible", true, 0.1)
	await get_tree().create_timer(duration).timeout
	tween.kill()
	sprite.show()


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

	var should_flip := direction < 0
	sprite.flip_h = should_flip


func _debug_states() -> void:
	if not debug_state:
		return

	for state: State in find_children("*", "State"):
		state.finished.connect(_on_state_finished_debug)


func _debug_velocity() -> void:
	if not debug_velocity:
		return

	Debug.log("Player velocity: %s" % velocity.round())


func _on_state_finished_debug(state: String, data := { }) -> void:
	if data.size() > 0:
		Debug.log("Player state changed to %s with %s" % [state, data])
		return

	Debug.log("Player state changed to %s" % state)


func _on_shoot_cooldown_timer_timeout() -> void:
	if player_mode != PlayerMode.Fire:
		_can_shoot = false
		return

	_can_shoot = true


func _on_invincibility_timer_timeout() -> void:
	is_invulnerable = false
	invincible_area.monitoring = false
	sprite.material.shader = null
	star_particles.emitting = false


func _on_invincible_area_body_entered(body: WalkingEnemy) -> void:
	body.hurt()
