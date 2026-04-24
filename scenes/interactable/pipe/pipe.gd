extends Interactable


@export_group("Properties")
@export var pipe_direction := Vector2.DOWN
@export var pipe_distance := 30.0
@export var pipe_speed := 1.0


func interact() -> void:
	super()
	
	if debug_enabled:
		Debug.log("Player interacted with pipe")
	
	_snap_player()
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	var pipe_movement := _get_marker_position() + pipe_direction * pipe_distance
	tween.tween_property(_player, "global_position", pipe_movement, pipe_speed)


func _on_detection_area_body_entered(body: Player) -> void:
	_player = body
	_player.set_interactable(self)


func _on_detection_area_body_exited(body: Player) -> void:
	body.unset_interactable()
	_player = null
