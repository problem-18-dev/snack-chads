class_name PlayerCamera
extends Camera2D

var left_boundary: float


func _physics_process(_delta: float) -> void:
	var new_left_boundary := global_position.x - get_viewport_rect().size.x / 3
	if new_left_boundary > left_boundary:
		left_boundary = new_left_boundary


func setup(new_limit_left: int, new_limit_right: int) -> void:
	limit_left = new_limit_left
	limit_right = new_limit_right
	left_boundary = left_boundary
