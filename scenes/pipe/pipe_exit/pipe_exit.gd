class_name PipeExit
extends StaticBody2D

@export_group("Properties")
@export var horizontal := false
@export_group("Animation")
@export var speed := 1.0
@export_group("Debug")
@export var debug_enabled := true

@onready var start_marker: Marker2D = $StartMarker
@onready var destination_marker: Marker2D = $DestinationMarker


func _ready() -> void:
	_adjust_markers()


func start(player: Player, is_return_point := false) -> void:
	if debug_enabled:
		Debug.log("Player exited pipe")

	if is_return_point:
		GameState.set_return_point(GameState.ReturnPoint.START)

	AudioManager.play_sfx(AudioManager.Sfx.PIPE)
	player.spawn(start_marker.global_position)
	var tween := create_tween()
	tween.tween_property(player, "global_position", destination_marker.global_position, speed)
	tween.tween_callback(player.start)


func _adjust_markers() -> void:
	if not horizontal:
		return

	start_marker.position.x += 8.0
	destination_marker.position.x += 8.0
