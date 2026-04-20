extends PlayerState


func _physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		finished.emit(PlayerState.AIR)
	
	player.move_and_slide()

func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true  })
