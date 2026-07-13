class_name Hittable
extends AnimatableBody2D

@onready var hit_ray_cast: RayCast2D = $HitRayCast


func hit() -> void:
	pass


func _check_hit() -> void:
	if hit_ray_cast.is_colliding():
		var collider := hit_ray_cast.get_collider()
		collider.die()
