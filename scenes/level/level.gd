class_name Level
extends Node2D

const PLAYER_PACKED = preload("uid://d251v5fi15bp4")

@export_group("Level")
@export var current_level: Main.Scene
@export var next_level: Main.Scene
@export var transition: Transition
@export_group("Properties")
@export var start_pipe: PipeExit
@export var update_player_left := true

var _player: Player

@onready var world: TileMapLayer = $WorldTileMapLayer
@onready var spawn_in_pipe := GameState.get_return_point() == GameState.ReturnPoint.PIPE
@onready var hud: HUD = $HUD


func _ready() -> void:
	if not transition or spawn_in_pipe:
		_start_level()
		return

	transition.show()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _prepare_player() -> void:
	_player = PLAYER_PACKED.instantiate()
	add_child(_player)
	_player.died.connect(_on_player_died)
	_player.consumed.connect(_on_player_consumed)
	_player.started.connect(_on_player_started)
	_player.finished_level.connect(_on_player_finished_level)

	var level_size := world.get_used_rect()
	var tile_size := world.tile_set.tile_size
	var limit_left := level_size.position.x * tile_size.x
	var limit_right := level_size.end.x * tile_size.x
	_player.setup_camera(limit_left, limit_right, update_player_left)
	_player.set_player_mode(GameState.player_mode)
	_player.enable_energy(GameState.player_energy_time_left)


func _spawn_player() -> void:
	_prepare_player()
	if spawn_in_pipe and start_pipe:
		assert(start_pipe, "Player to spawn in pipe, but pipe doesn't exist.")
		start_pipe.start(_player)
		return

	var spawn_marker: Marker2D = $Markers/SpawnMarker
	var spawn_position := spawn_marker.position
	_player.spawn(spawn_position)
	_player.start()


func _start_level() -> void:
	call_deferred("_spawn_player")
	get_tree().call_deferred("call_group", "enemies", "resume")
	get_tree().call_deferred("call_group", "pushables", "resume")


func _toggle_pause() -> void:
	var paused := get_tree().paused

	if not paused:
		get_tree().paused = true
		hud.pause()
		return

	hud.unpause()
	get_tree().paused = false


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


func _on_hud_game_quit() -> void:
	GameManager.main.load_scene(Main.Scene.MAIN_MENU)


func _on_hud_game_resumed() -> void:
	_toggle_pause()


func _on_transition_visibility_changed() -> void:
	if transition and not transition.visible:
		_start_level()
