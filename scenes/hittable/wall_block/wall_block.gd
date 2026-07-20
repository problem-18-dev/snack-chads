extends Block

@onready var particles: CPUParticles2D = $CPUParticles2D


func hit() -> void:
	_check_hit()
	sprite.hide()
	particles.emitting = true
	await particles.finished
	_destroy()


func _destroy() -> void:
	queue_free()
