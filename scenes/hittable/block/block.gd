class_name Block
extends Hittable

@export_group("Bump")
@export var bump_offset := 4.0
@export var bump_duration := 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _rest_position: Vector2
var _bump_tween: Tween


func _ready() -> void:
	_rest_position = position


func bump() -> void:
	if _bump_tween and _bump_tween.is_valid():
		_bump_tween.kill()

	position = _rest_position

	_bump_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_bump_tween.tween_callback(_check_hit)
	_bump_tween.tween_property(self, "position", _rest_position + Vector2.UP * bump_offset, bump_duration / 2)
	_bump_tween.tween_property(self, "position", _rest_position, bump_duration / 2)
