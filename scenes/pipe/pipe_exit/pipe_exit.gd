class_name PipeExit
extends StaticBody2D


enum Direction { Right, Top, Bottom, Left }


@export_group("Properties")
@export var horizontal := false
@export_group("Animation")
@export var speed := 1.0
@export var direction := Direction.Top
@export_group("Debug")
@export var debug_enabled := false

@onready var start_marker: Marker2D = $StartMarker
@onready var destination_marker: Marker2D = $DestinationMarker


func _ready() -> void:
	_adjust_markers()


func start(player: Player) -> void:
	if debug_enabled:
		Debug.log("Player exited pipe")
	
	player.spawn(start_marker.global_position)
	var tween := create_tween()
	tween.tween_property(player, "global_position", destination_marker.global_position, speed)
	tween.tween_callback(player.start)


func _adjust_markers() -> void:
	if not horizontal:
		return
	
	start_marker.position.x += 8.0
	destination_marker.position.x += 8.0
