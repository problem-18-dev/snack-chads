class_name Level
extends Node2D

const PLAYER_PACKED = preload("uid://d251v5fi15bp4")

@export_group("Level")
@export var current_level: Main.Scene
@export var transition: Transition
@export var next_level: Main.Scene
@export_group("Properties")
@export var start_pipe: PipeExit
@export var update_player_left := true

@onready var world: TileMapLayer = $WorldTileMapLayer
@onready var spawn_in_pipe := GameState.get_return_point() == GameState.ReturnPoint.PIPE


func _ready() -> void:
	if not transition or spawn_in_pipe:
		_start_level()
		return

	transition.show()


func _prepare_player() -> Player:
	var player: Player = PLAYER_PACKED.instantiate()
	add_child(player)
	player.died.connect(_on_player_died)
	player.consumed.connect(_on_player_consumed)
	player.started.connect(_on_player_started)
	player.finished_level.connect(_on_player_finished_level)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := level_size.end.x * tile_size.x
	player.setup_camera(limit_left, limit_right, update_player_left)
	player.set_player_mode(GameState.player_mode)
	player.enable_energy(GameState.player_energy_time_left)
	return player


func _spawn_player() -> void:
	var player := _prepare_player()

	if spawn_in_pipe and start_pipe:
		assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
		start_pipe.start(player)
		return

	var spawn_marker: Marker2D = $Markers/SpawnMarker
	var spawn_position := spawn_marker.position
	player.spawn(spawn_position)
	player.start()


func _start_level() -> void:
	call_deferred("_spawn_player")
	get_tree().call_deferred("call_group", "enemies", "resume")
	get_tree().call_deferred("call_group", "pushables", "resume")


func _on_player_died() -> void:
	GameState.reset()
	# Next level is always next pointer, so -1 is same level
	GameManager.main.load_scene(current_level)


func _on_player_consumed() -> void:
	get_tree().call_group("enemies", "pause")
	get_tree().call_group("pushables", "pause")


func _on_player_started() -> void:
	get_tree().call_group("enemies", "resume")
	get_tree().call_group("pushables", "resume")


func _on_player_finished_level() -> void:
	GameManager.main.load_scene(next_level)


func _on_transition_hidden() -> void:
	_start_level()
