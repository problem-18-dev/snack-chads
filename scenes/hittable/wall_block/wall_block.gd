extends Block


func hit() -> void:
	_destroy()


func _destroy() -> void:
	queue_free()
