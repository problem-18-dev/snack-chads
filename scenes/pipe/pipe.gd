class_name Pipe
extends Node2D

@export_group("Pipe")
@export var pipe_direction := Vector2.DOWN
@export var pipe_distance := 30.0
@export var pipe_speed := 1.0
@export_group("Debug")
@export var debug_enabled := false

var _player: Player

@onready var start_marker_2d: Marker2D = $StartMarker2D


func take_player() -> void:
	assert(_player, "Pipe attempting to take player, but player is null.")
	
	_player.global_position = start_marker_2d.global_position
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	var pipe_movement := start_marker_2d.global_position + pipe_direction * pipe_distance
	tween.tween_property(_player, "global_position", pipe_movement, pipe_speed)
	await tween.finished
	
	if debug_enabled:
		Debug.log("Player moves")


func _on_area_2d_body_entered(body: Player) -> void:
	body.set_pipe(self)
	_player = body
	
	if debug_enabled:
		Debug.log("Player can enter pipe")


func _on_area_2d_body_exited(body: Player) -> void:
	body.unset_pipe()
	_player = null
