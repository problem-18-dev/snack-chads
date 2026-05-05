extends Node


enum ReturnPoint { Start, CheckPoint, Pipe }

var player_state := {}
var return_point := ReturnPoint.Start


func save_player_state(player: Player) -> void:
	player_state = {
		"is_grown": player.is_grown,
	}


func get_return_point() -> ReturnPoint:
	return return_point


func set_return_point(new_return_point: ReturnPoint) -> void:
	return_point = new_return_point
