extends PlayerState


const DEATH_JUMP_FORCE := 250.0

var _is_dead := false


func _enter(data := {}) -> void:
	if data.has("interactable"):
		var interactable = data.interactable
		interactable.interact()
		return
	
	if data.has("death"):
		_die()


func _physics_update(delta: float) -> void:
	if not _is_dead:
		return
	
	_apply_gravity(delta)
	player.move_and_slide()


func _die() -> void:
	_is_dead = true
	player.velocity = Vector2(0, -DEATH_JUMP_FORCE)
	player.collision_shape.set_deferred("disabled", true)
	player.invincible_area.monitoring = false


func _apply_gravity(delta: float) -> void:
	var death_gravity := player.get_gravity().y / 2
	player.velocity.y += death_gravity * delta
