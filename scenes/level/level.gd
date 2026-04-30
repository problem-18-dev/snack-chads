class_name Level
extends Node


@export_group("Level")
@export var pipe_exit: PipeExit
@export_group("Player")
@export var player_packed: PackedScene

@onready var spawn_marker: Marker2D = $Markers/SpawnMarker
@onready var world: TileMapLayer = $WorldTileMapLayer


func _ready() -> void:
	_spawn_player()


func _spawn_player() -> void:
	var player: Player = player_packed.instantiate()
	add_child(player)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := (level_size.size.x * tile_size.x) - 48
	player.setup(limit_left, limit_right)
	
	if pipe_exit:
		assert(pipe_exit, "Player to spawn in pipe, but pipe doesn't exist.")
		pipe_exit.start(player)
		return
	
	var spawn_position := spawn_marker.position
	player.spawn(spawn_position)
	player.start()
