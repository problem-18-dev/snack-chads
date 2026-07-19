class_name PlayerCamera
extends Camera2D

var left_boundary: float
var can_update_left := true


func _physics_process(_delta: float) -> void:
	var new_left_boundary := global_position.x - get_viewport_rect().size.x / 3
	if can_update_left and new_left_boundary > left_boundary:
		left_boundary = new_left_boundary


func setup(new_limit_left: int, new_limit_right: int, should_update_left := true) -> void:
	limit_left = new_limit_left
	limit_right = new_limit_right
	left_boundary = new_limit_left
	can_update_left = should_update_left
