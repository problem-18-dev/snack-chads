extends Consumable

@export_group("Bounce")
@export var bounce_force := 350.0


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	move_and_slide()
	_handle_collision()


func _handle_movement(delta: float) -> void:
	super(delta)

	if is_on_floor():
		velocity.y = -bounce_force
