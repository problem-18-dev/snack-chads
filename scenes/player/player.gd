class_name Player
extends CharacterBody2D

signal died
signal fired
signal consumed
signal started
signal finished_level

enum PlayerMode { NORMAL, LARGE, LOLLY_POP }

const ENEMY_MASK_LAYER := 6
const PROJECTILE: PackedScene = preload("uid://dvmwy36oldp5")
const INVINCIBILITY_SHADER: Shader = preload("uid://u1wm04bxa3qy")
const PLAYER_RESOURCES := {
	PlayerMode.NORMAL: preload("uid://bkxnhau8jvgdv"),
	PlayerMode.LARGE: preload("uid://bqgwcyojoi3a1"),
	PlayerMode.LOLLY_POP: preload("uid://dcsb3nuldr7a7"),
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
@export var bounce_force := 150.0
@export var bounce_force_multiplier := 3.0
@export_subgroup("Walking")
@export var walk_speed := 125.0
@export var walk_accel := 0.2
@export var walk_deccel := 0.15
@export_subgroup("Running")
@export var run_speed := 175.0
@export var run_accel := 0.2
@export_group("Interactions")
@export var pipe_maximum_speed := 10.0
@export_group("Player Mode Change")
@export var player_mode_upgrade_duration := 0.5
@export var damage_invincibility_duration := 2.0
@export var damage_pause_duration := 0.5
@export_subgroup("Energy")
@export var energy_duration := 10.0
@export var energy_warning_treshold := 2.0
@export_group("Death")
@export var death_pause := 0.5
@export var death_jump_distance := 64.0
@export var death_duration := 0.75
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

var player_mode := PlayerMode.NORMAL
var is_energized := false
var _interactable: Interactable
var _can_shoot := false
var _can_take_damage := true

@onready var jump_buffer_ray_casts: Array[RayCast2D] = [
	$Raycasts/LeftJumpBufferRayCast,
	$Raycasts/RightJumpBufferRayCast,
]
@onready var hit_raycasts: Array[RayCast2D] = [
	$Raycasts/LeftUpperHitRaycast,
	$Raycasts/RightUpperHitRaycast,
]
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_marker: Marker2D = $ShootMarker
@onready var energy_area: Area2D = $EnergyArea
@onready var shoot_cooldown_timer: Timer = $ShootCooldownTimer
@onready var energy_timer: Timer = $EnergyTimer
@onready var ground_particles: CPUParticles2D = $AnimatedSprite2D/GroundParticles
@onready var energy_particles: CPUParticles2D = $AnimatedSprite2D/EnergyParticles
@onready var land_particles: CPUParticles2D = $AnimatedSprite2D/LandParticles
@onready var flicker_component: FlickerComponent = $FlickerComponent
@onready var elastic_land_component: Node2D = $ElasticLandComponent
@onready var energy_audio_player: AudioStreamPlayer = $EnergyAudioPlayer


func _ready() -> void:
	_debug_states()
	_prepare()


func _process(_delta: float) -> void:
	_flicker_on_low_energy()


func _physics_process(_delta: float) -> void:
	_limit_movement()
	_flip_sprite()
	_debug_velocity()


func start() -> void:
	state_machine.transition_to_state(PlayerState.AIR)


func spawn(spawn_position: Vector2, camera_instant := true) -> void:
	global_position = spawn_position
	if camera_instant:
		player_camera.align()
		player_camera.reset_smoothing()


func setup_camera(limit_left: int, limit_right: int, should_update_left := true) -> void:
	player_camera.setup(limit_left, limit_right, should_update_left)


func take_damage() -> void:
	if not _can_take_damage:
		return

	if is_large():
		AudioManager.play_sfx(AudioManager.Sfx.PLAYER_HURT)
		player_camera.screen_shake(PlayerCamera.SMALL_INTENSITY, PlayerCamera.SHORT_LENGTH)
		_downgrade_player_mode()
		return

	player_camera.screen_shake(PlayerCamera.MEDIUM_INTENSITY, PlayerCamera.LONG_LENGTH)
	die()


func die() -> void:
	AudioManager.play_sfx(AudioManager.Sfx.GAME_OVER)
	state_machine.transition_to_state(PlayerState.IMMOBILE, { "death": true })


func consume(consumable: Consumable.Type) -> void:
	AudioManager.play_sfx(AudioManager.Sfx.CONSUME)
	match consumable:
		Consumable.Type.ENERGY_DRINK:
			enable_energy()
		Consumable.Type.BACKPACK:
			_upgrade_player_mode(PlayerMode.LARGE)
		Consumable.Type.LOLLY_POP:
			_upgrade_player_mode(PlayerMode.LOLLY_POP)
		_:
			push_error("Consumable not handled: ", consumable)


func shrink() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.NORMAL].sprite_frames
	animation_player.play("shrink")

	if debug_player_mode:
		Debug.log("Player shrinks")


func enlarge() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.LARGE].sprite_frames
	animation_player.play("large")

	if debug_player_mode:
		Debug.log("Player grows large")


func enable_lolly_pop() -> void:
	sprite.sprite_frames = PLAYER_RESOURCES[PlayerMode.LOLLY_POP].sprite_frames
	animation_player.play("fire")
	_can_shoot = true

	if debug_player_mode:
		Debug.log("Player is in fire mode!")


func can_use_pipe() -> bool:
	return abs(velocity.x) < pipe_maximum_speed


func is_large() -> bool:
	return player_mode != PlayerMode.NORMAL


func shoot() -> void:
	if not _can_shoot:
		return

	AudioManager.play_sfx(AudioManager.Sfx.FIREBALL)
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
	return is_large()


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
		PlayerMode.LARGE:
			enlarge()
		PlayerMode.LOLLY_POP:
			enable_lolly_pop()
		_:
			shrink()

	player_mode = new_player_mode


func get_remaining_energy_time() -> float:
	if energy_timer.is_stopped():
		return 0.0

	return energy_timer.time_left


func enable_energy(duration := energy_duration) -> void:
	if is_zero_approx(duration):
		return

	if debug_player_mode:
		Debug.log("Player is in star mode for %s sec!" % duration)

	energy_audio_player.play()
	is_energized = true
	energy_area.monitoring = true
	energy_timer.start(duration)
	sprite.material.shader = INVINCIBILITY_SHADER
	energy_particles.emitting = true
	set_collision_mask_value(ENEMY_MASK_LAYER, false)


func walk_to(destination: Vector2) -> void:
	state_machine.transition_to_state(PlayerState.IMMOBILE, { "walk_to": destination })


func _upgrade_player_mode(new_player_mode: PlayerMode) -> void:
	consumed.emit()

	# Save state, pause player
	var previous_state := state_machine.get_current_state()
	state_machine.transition_to_state(PlayerState.IMMOBILE)

	if new_player_mode > player_mode:
		set_player_mode(new_player_mode)
		await get_tree().create_timer(player_mode_upgrade_duration).timeout
	elif new_player_mode <= player_mode:
		# Bonus points
		pass

	state_machine.transition_to_state(previous_state)
	started.emit()


func _downgrade_player_mode() -> void:
	# Will always downgrade from LOLLY_POP at maximum
	if _can_shoot:
		_can_shoot = false

	set_player_mode(player_mode - 1)
	_grant_invincibility(damage_invincibility_duration)
	await _pause(damage_pause_duration)


func _grant_invincibility(duration: float) -> void:
	_can_take_damage = false
	set_collision_mask_value(ENEMY_MASK_LAYER, false)
	await flicker_component.flicker(duration)
	set_collision_mask_value(ENEMY_MASK_LAYER, true)
	_can_take_damage = true


func _pause(duration: float) -> void:
	var previous_state := state_machine.get_current_state()
	state_machine.transition_to_state(PlayerState.IMMOBILE)
	await get_tree().create_timer(duration).timeout
	state_machine.transition_to_state(previous_state)


func _prepare() -> void:
	sprite.material.shader = null
	energy_area.monitoring = false
	energy_timer.wait_time = energy_duration


func _limit_movement() -> void:
	var limit_left := player_camera.limit_left
	var limit_right := player_camera.limit_right
	var current_position := global_position.x
	current_position = clampf(current_position, limit_left, limit_right)

	if is_equal_approx(current_position, limit_left):
		global_position.x = limit_left
		velocity.x = 0

	if current_position < player_camera.left_boundary:
		global_position.x = player_camera.left_boundary
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


func _flicker_on_low_energy() -> void:
	if not is_energized or flicker_component.is_flickering():
		return

	if energy_timer.time_left <= energy_warning_treshold:
		flicker_component.flicker(energy_warning_treshold)


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
	_can_shoot = player_mode == PlayerMode.LOLLY_POP


func _on_energy_timer_timeout() -> void:
	is_energized = false
	energy_area.monitoring = false
	sprite.material.shader = null
	energy_particles.emitting = false
	energy_audio_player.stop()
	set_collision_mask_value(ENEMY_MASK_LAYER, true)


func _on_energy_area_body_entered(body: WalkingEnemy) -> void:
	AudioManager.play_sfx(AudioManager.Sfx.STOMP)
	body.hurt()
