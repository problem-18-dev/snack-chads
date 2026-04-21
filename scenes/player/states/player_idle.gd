extends PlayerState


func _enter(_data := {}) -> void:
	player.velocity = Vector2.ZERO


func _physics_update(_delta: float) -> void:
	player.move_and_slide()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })
		return
	
	if event.is_action_pressed("left") or event.is_action_pressed("right"):
		finished.emit(PlayerState.WALK)
