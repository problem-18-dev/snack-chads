class_name Level
extends Node


@export_group("Player")
@export var player_packed: PackedScene

@onready var spawn_marker: Marker2D = $Markers/SpawnMarker
@onready var limit_marker: Marker2D = $Markers/LimitMarker
@onready var world_tile_map_layer: TileMapLayer = $WorldTileMapLayer



func _ready() -> void:
	_spawn_player()


func _spawn_player() -> void:
	var player: Player = player_packed.instantiate()
	var spawn_position := spawn_marker.position
	add_child(player)
	var left_limit := roundi(limit_marker.position.x)
	player.setup(spawn_position, left_limit)
