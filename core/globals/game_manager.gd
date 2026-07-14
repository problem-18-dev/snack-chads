extends Node

var main: Main
var _next_level: Main.Scene


func set_next_level(next_level: Main.Scene) -> void:
	_next_level = next_level


func get_next_level() -> Main.Scene:
	return _next_level
