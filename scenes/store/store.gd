class_name Store
extends Node2D

@onready var destination_marker: Marker2D = $DestinationMarker


func get_destination_global_position() -> Vector2:
	return destination_marker.global_position
