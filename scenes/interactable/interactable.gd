class_name Interactable
extends Node2D

@export_group("Snapping")
@export var snap_animated := true
@export var snap_duration := 0.1
@export_group("Debug")
@export var debug_enabled := false

var _player: Player
var _snap_tween: Tween

@onready var snap_marker_2d: Marker2D = $SnapMarker2D


func interact() -> void:
	assert(_player, "Interaction attempted, but player is null.")


func _get_marker_position() -> Vector2:
	return snap_marker_2d.global_position


func _adjust_marker(new_position: Vector2) -> void:
	snap_marker_2d.position = new_position


func _snap_player() -> void:
	if not snap_animated:
		_player.global_position = _get_marker_position()
		return
	
	_snap_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_snap_tween.tween_property(_player, "global_position", _get_marker_position(), snap_duration)
	await _snap_tween.finished


func _on_detection_area_body_entered(_body: Player) -> void:
	pass


func _on_detection_area_body_exited(_body: Player) -> void:
	pass
