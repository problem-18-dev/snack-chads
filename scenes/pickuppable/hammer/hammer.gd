extends Pickuppable

@export_group("Target")
@export var target_body: CharacterBody2D


func start() -> void:
	_pick_up()


func _pick_up() -> void:
	picked_up.emit(Pickuppable.HAMMER)
	target_body.die()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_pick_up()
