class_name Level
extends Node


@export_group("Properties")
@export var left_boundary := 192
@export_group("Player")
@export var player_packed: PackedScene

@onready var spawn_marker: Marker2D = $SpawnMarker



func _ready() -> void:
	_spawn_player()


func _spawn_player() -> void:
	var player: Player = player_packed.instantiate()
	var spawn_position := spawn_marker.global_position
	add_child(player)
	player.setup(spawn_position)
