extends PlayerState


func _enter(_data := {}) -> void:
	if _data.has("jump"):
		player.velocity.y = -player.jump_force

func _physics_update(delta: float) -> void:
	if player.is_on_floor():
		finished.emit(PlayerState.IDLE)
	
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()
