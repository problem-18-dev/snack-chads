class_name PlayerCamera
extends Camera2D

const SMALL_INTENSITY := 0.5
const MEDIUM_INTENSITY := 1.5
const LARGE_INTENSITY := 2.5
const SHORT_LENGTH := 0.125
const LONG_LENGTH := 0.25

var left_boundary: float
var can_update_left := true
# Shake
var shake_intensity := 0.0
var active_shake_time := 0.0
var shake_decay := 5.0
var shake_time := 0.0
var shake_time_speed := 20.0
var noise := FastNoiseLite.new()

@onready var shake_initial_offset := offset


func _physics_process(delta: float) -> void:
	var new_left_boundary := global_position.x - get_viewport_rect().size.x / 3
	if can_update_left and new_left_boundary > left_boundary:
		left_boundary = new_left_boundary

	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta

		offset = shake_initial_offset + Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity,
		)
	else:
		offset = offset.lerp(shake_initial_offset, 10.5 * delta)


func setup(new_limit_left: int, new_limit_right: int, should_update_left := true) -> void:
	limit_left = new_limit_left
	limit_right = new_limit_right
	left_boundary = new_limit_left
	can_update_left = should_update_left


func screen_shake(intensity: float, time: float) -> void:
	noise.seed = randi()
	noise.frequency = 2.0

	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0
