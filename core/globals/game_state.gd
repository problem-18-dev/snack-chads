extends Node

signal points_changed(points: int)
signal points_added(amount: int, at: Vector2)
signal time_changed(seconds: int)
signal time_stopped

enum ReturnPoint { START, PIPE }

const DEFAULT_LIVES := 5

var player_mode := Player.PlayerMode.NORMAL
var player_energy_time_left := 0.0
var return_point := ReturnPoint.START
var points := 0
var lives := DEFAULT_LIVES
var time_left := 0


func save_player_mode(current_player_mode: Player.PlayerMode) -> void:
	player_mode = current_player_mode


func save_player_energy_time(new_energy_time_left: float) -> void:
	player_energy_time_left = new_energy_time_left


func get_return_point() -> ReturnPoint:
	return return_point


func set_return_point(new_return_point: ReturnPoint) -> void:
	return_point = new_return_point


func add_points(new_points: int, at: Vector2) -> void:
	points += new_points
	points_added.emit(new_points, at)
	points_changed.emit(points)


func set_time(seconds: int) -> void:
	time_left = seconds
	time_changed.emit(time_left)


func decrement_time() -> void:
	time_left = maxi(time_left - 1, 0)
	time_changed.emit(time_left)


func stop_time() -> void:
	time_stopped.emit()


func reset_player() -> void:
	player_mode = Player.PlayerMode.NORMAL
	player_energy_time_left = 0.0
	return_point = ReturnPoint.START


func reset_game_state() -> void:
	reset_player()
	lives = DEFAULT_LIVES
	points = 0
	time_left = 0
