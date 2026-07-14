class_name Level
extends Node2D

const PLAYER_PACKED = preload("uid://d251v5fi15bp4")

@export_group("Level")
@export var next_level: Main.Scene
@export_group("Properties")
@export var start_pipe: PipeExit

@onready var world: TileMapLayer = $WorldTileMapLayer


func _ready() -> void:
	_spawn_player()


func _prepare_player() -> Player:
	var player: Player = PLAYER_PACKED.instantiate()
	add_child(player)
	player.consumed.connect(_on_player_consumed)
	player.started.connect(_on_player_started)
	player.finished_level.connect(_on_player_finished_level)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := (level_size.size.x * tile_size.x) - 48
	player.setup_camera(limit_left, limit_right)
	player.set_player_mode(GameState.player_mode)
	player.enable_invincibility(GameState.player_invincibility_time_left)
	return player


func _spawn_player() -> void:
	var player := _prepare_player()

	var spawn_in_pipe := GameState.get_return_point() == GameState.ReturnPoint.PIPE
	if spawn_in_pipe and start_pipe:
		assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
		start_pipe.start(player)
		return

	var spawn_marker: Marker2D = $Markers/SpawnMarker
	var spawn_position := spawn_marker.position
	player.spawn(spawn_position)
	player.start()


func _on_player_consumed() -> void:
	get_tree().call_group("enemies", "pause")


func _on_player_started() -> void:
	get_tree().call_group("enemies", "resume")


func _on_player_finished_level() -> void:
	GameManager.set_next_level(next_level)
	GameManager.main.load_scene(Main.Scene.TRANSITION)
