class_name Level
extends Node2D


const PLAYER_PACKED = preload("uid://d251v5fi15bp4")

@export_group("Level")
@export var start_pipe: PipeExit

@onready var world: TileMapLayer = $WorldTileMapLayer


func _ready() -> void:
	_spawn_player()


func _spawn_player() -> void:
	var player: Player = PLAYER_PACKED.instantiate()
	add_child(player)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := (level_size.size.x * tile_size.x) - 48
	player.setup(limit_left, limit_right)
	
	var spawn_in_pipe := GameState.get_return_point() == GameState.ReturnPoint.Pipe
	if spawn_in_pipe and start_pipe:
		assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
		start_pipe.start(player)
		return
	
	var spawn_marker: Marker2D = $Markers/SpawnMarker
	var spawn_position := spawn_marker.position
	player.spawn(spawn_position)
	player.start()
