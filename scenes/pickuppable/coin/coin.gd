extends Pickuppable


func _pick_up() -> void:
	picked_up.emit(Pickuppable.COIN)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_pick_up()
