extends CharacterBody2D

const ENEMY_LAYER := 6
const SLIPPER_SCENE := preload("uid://b87ptsubfqo8e")

@export_group("Moving")
@export var speed := 30.0
@export var from_marker: Marker2D
@export var to_marker: Marker2D
@export_group("Attacking")
@export var attack_time_minimum := 1.25
@export var attack_time_maximum := 2.25
@export_group("Jumping")
@export var jump_force := 300.0
@export var jump_time_minimum := 1.5
@export var jump_time_maximum := 3.75

var _move_tween: Tween

@onready var jump_timer: Timer = $JumpTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_marker: Marker2D = $AttackMarker
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D


func _ready() -> void:
	jump_timer.wait_time = _get_random_jump_time()
	attack_timer.wait_time = _get_random_attack_time()
	jump_timer.start()
	attack_timer.start()

	_walk()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += (get_gravity().y / 2) * delta

	move_and_slide()


func die() -> void:
	visible_on_screen_enabler_2d.queue_free()
	_move_tween.kill()
	sprite.play("death")
	attack_timer.stop()
	jump_timer.stop()
	set_collision_layer_value(ENEMY_LAYER, false)


func _walk() -> void:
	_move_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	_move_tween.tween_property(self, "global_position:x", from_marker.global_position.x, 2.0)
	_move_tween.tween_property(self, "global_position:x", to_marker.global_position.x, 2.0)


func _attack() -> void:
	# Spawn slipper
	AudioManager.play_sfx(AudioManager.Sfx.SLIPPER_THROW)
	var slipper := SLIPPER_SCENE.instantiate()
	slipper.start(attack_marker.global_position)
	get_parent().add_child(slipper)

	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("walk")


func _get_random_jump_time() -> float:
	return randf_range(jump_time_minimum, jump_time_maximum)


func _get_random_attack_time() -> float:
	return randf_range(attack_time_minimum, attack_time_maximum)


func _on_jump_timer_timeout() -> void:
	print("Jumped")
	velocity.y = -jump_force
	jump_timer.start(_get_random_jump_time())


func _on_attack_timer_timeout() -> void:
	_attack()
	attack_timer.start(_get_random_attack_time())
