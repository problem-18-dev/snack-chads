extends Node

enum ReturnPoint { START, CHECK_POINT, PIPE }

var player_mode := Player.PlayerMode.Fire
var player_invincibility_time_left := 0.0
var return_point := ReturnPoint.START


func save_player_mode(current_player_mode: Player.PlayerMode) -> void:
	player_mode = current_player_mode


func save_player_invincibility_time(new_invincibility_time_left: float) -> void:
	player_invincibility_time_left = new_invincibility_time_left


func get_return_point() -> ReturnPoint:
	return return_point


func set_return_point(new_return_point: ReturnPoint) -> void:
	return_point = new_return_point
