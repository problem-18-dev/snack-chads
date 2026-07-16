extends Pickuppable

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func start() -> void:
	_pick_up()


func _pick_up() -> void:
	picked_up.emit(Pickuppable.COIN)
	collision_shape.set_deferred("disabled", true)
	animation_player.play("pick_up")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_pick_up()
