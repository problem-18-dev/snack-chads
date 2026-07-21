extends Node


func get_points_text(points: int) -> String:
	return str("%06d" % points)


func get_time_text(seconds: int) -> String:
	return str("%03d" % seconds)
